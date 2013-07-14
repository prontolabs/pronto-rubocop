module Pronto
  class Rubocop
    def run(diffs)
      return [] unless diffs && diffs.any?
    end
  end
end
