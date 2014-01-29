module Inch
  module CLI
    module Command
      class Suggest < List
        def description
          'Suggests some objects to be doucmented (better)'
        end

        def usage
          'Usage: inch suggest [paths] [options]'
        end

        # Runs the commandline utility, parsing arguments and displaying a
        # list of objects
        #
        # @param [Array<String>] args the list of arguments.
        # @return [void]
        def run(*args)
          prepare_list(*args)
          Output::Suggest.new(@options, objects_to_display, relevant_objects, @ranges, files)
        end

        def objects_to_display
          @objects_to_display ||= filter_objects_to_display
        end

        def filter_objects_to_display
          list = []
          @options.grades_to_display.map do |grade|
            r = range(grade)
            arr = select_by_priority(r.objects, @options.object_min_priority)
            arr = arr.select { |o| o.score <= @options.object_max_score }
            list.concat arr
          end

          list = sort_by_priority(list)

          if list.size > @options.object_count
            list = list[0...@options.object_count]
          elsif list.size < @options.object_count
            # should we add objects with lower priority to fill out the
            # requested count?
          end
          list
        end

        def files
          list = files_sorted_by_importance
          how_many = @options.file_count || list.size
          list[0...how_many]
        end

        def files_sorted_by_importance
          list = all_filenames(relevant_objects).uniq.map do |filename|
            f = Evaluation::File.for(filename, relevant_objects)
          end

          list = list.select do |f|
            relevant_grades.include?(f.grade) &&
              relevant_priorities.include?(f.priority)
          end

          sort_by_priority(list)
        end

        def all_filenames(objects)
          objects.map do |o|
            o.files.map(&:first)
          end.flatten
        end

        # Returns the unique grades assigned to objects
        #
        #   grades # => [:A, :B, :C, :U]
        #
        # @return [Array<Symbol>]
        def grades
          objects.map(&:grade).uniq
        end

        def range(grade)
          @ranges.detect { |r| r.grade == grade }
        end

        def relevant_objects
          select_by_priority(objects, @options.object_min_priority)
        end

        def relevant_grades
          grades.size >= 2 ? grades[-2..-1] : [grades.last].compact
        end

        def relevant_priorities
          (@options.object_min_priority..99)
        end

        def select_by_priority(list, min_priority)
          list.select { |o| o.priority >= min_priority }
        end

      end
    end
  end
end