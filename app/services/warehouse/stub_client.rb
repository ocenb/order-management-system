module Warehouse
  class StubClient
    class ProcessingError < StandardError; end

    def self.process!(order)
      new.process!(order)
    end

    def process!(order)
      # Deterministic failure hook for tests and manual checks.
      raise ProcessingError, "Warehouse validation failed" if order.external_id.to_s.start_with?("fail-")

      true
    end
  end
end
