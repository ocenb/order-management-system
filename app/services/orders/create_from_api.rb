module Orders
  class CreateFromApi
    Result = Struct.new(:order, :created, keyword_init: true)

    def self.call(attributes)
      new(attributes).call
    end

    def initialize(attributes)
      @attributes = attributes.deep_symbolize_keys
    end

    def call
      order = Order.find_by(source: @attributes.fetch(:source), external_id: @attributes.fetch(:external_id))
      return Result.new(order:, created: false) if order

      created_order = nil

      Order.transaction do
        created_order = Order.create!(order_attributes)
        created_order.order_status_events.create!(from_status: nil, to_status: :pending)
      end

      created_order.enqueue_processing!

      Result.new(order: created_order, created: true)
    rescue ActiveRecord::RecordNotUnique
      # Idempotency race: if another transaction inserted first, return persisted record.
      order = Order.find_by!(source: @attributes.fetch(:source), external_id: @attributes.fetch(:external_id))
      Result.new(order:, created: false)
    end

    private

    def order_attributes
      @attributes.slice(
        :source,
        :external_id,
        :customer_email,
        :customer_name,
        :delivery_address,
        :total_amount,
        :currency
      ).merge(
        status: :pending,
        order_items_attributes: normalized_items
      )
    end

    def normalized_items
      Array(@attributes[:items]).map do |item|
        item.deep_symbolize_keys.slice(:sku, :name, :quantity, :price)
      end
    end
  end
end
