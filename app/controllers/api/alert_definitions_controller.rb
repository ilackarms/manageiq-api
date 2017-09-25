module Api
  class AlertDefinitionsController < BaseController

    before_action :set_additional_attributes

    def create_resource(type, id, data = {})
      assert_id_not_specified(data, type)
      begin
        create_miq_expression(data)
        data["enabled"] = true if data["enabled"].nil?
        super(type, id, data.deep_symbolize_keys).serializable_hash.merge("expression" => expression_values(data).first)
      rescue => err
        raise BadRequestError, "Failed to create a new alert definition - #{err}"
      end
    end

    def edit_resource(type, id = nil, data = {})
      raise BadRequestError, "Must specify an id for editing a #{type} resource" unless id
      if expression_values(data).size == 1
        if data["hash_expression"]
          data["miq_expression"] = nil
        else
          data["hash_expression"] = nil
        end
      end
      begin
        create_miq_expression(data)
        super(type, id, data.deep_symbolize_keys)
      rescue => err
        raise BadRequestError, "Failed to update alert definition - #{err}"
      end
    end

    private

    def set_additional_attributes
      @additional_attributes = %w(expression)
    end

    def expression_values(data)
      data.slice("expression", "miq_expression", "hash_expression").values.compact
    end

    def create_miq_expression(data)
      data["expression"] = MiqExpression.new(data["expression"]) if data["expression"]
      data["miq_expression"] = MiqExpression.new(data["miq_expression"]) if data["miq_expression"]
    end
  end
end
