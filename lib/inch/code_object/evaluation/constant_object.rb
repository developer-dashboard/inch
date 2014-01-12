module Inch
  module CodeObject
    module Evaluation
      class ConstantObject < Base
        DOC_SCORE = MAX_SCORE

        def evaluate
          if object.has_doc?
            add_score DOC_SCORE
          end
        end
      end
    end
  end
end