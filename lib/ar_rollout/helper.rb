module ArRollout
  module Controller
    module Helpers
      def self.included(base)
        base.send :helper_method, :rollout?
        base.send :helper_method, :degrade_feature?
      end

      def rollout?(name)
        ArRollout.active?(name, current_user)
      end

      def degrade_feature?(name)
        ArRollout.degrade_feature?(name)
      end
    end
  end
end
