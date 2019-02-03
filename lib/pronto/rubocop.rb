require 'pronto'
require 'rubocop'
require 'pronto/rubocop/patch_cop'

module Pronto
  class Rubocop < Runner
    def run
      ruby_patches
        .select { |patch| patch.additions > 0 }
        .map { |patch| PatchCop.new(patch, self).messages }
        .flatten
    end
  end
end
