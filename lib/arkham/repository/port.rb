module Arkham
  module Repository
    module Port
      def within_transaction(&block)
        raise NotImplementedError, "#{self.class} must implement #within_transaction"
      end

      def find_all(filter_params = {})
        raise NotImplementedError, "#{self.class} must implement #find_all"
      end

      def find_by_id(id)
        raise NotImplementedError, "#{self.class} must implement #find_by_id"
      end

      def create(params)
        raise NotImplementedError, "#{self.class} must implement #create"
      end

      def update(id, params)
        raise NotImplementedError, "#{self.class} must implement #update"
      end

      def destroy(id)
        raise NotImplementedError, "#{self.class} must implement #destroy"
      end
    end
  end
end
