require 'fileutils'

module Fastlane
  module Actions
  
    class CleanAction < Action
      def self.run(params)
        
        Dir.glob('**/bin').each do |f| 
          FileUtils.rm_rf(f) if File.directory?(f)
        end

        Dir.glob('**/obj').each do |f| 
          FileUtils.rm_rf(f) if File.directory?(f)
        end
        
      end

      def self.description
        "Clean artifacts"
      end

      def self.authors
        ["Thomas Charriere"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Clean bin and bin folders - best done before a build"
      end


      def self.available_options
        [
        ]

      end

      def self.is_supported?(platform)
        [:android, :ios].include?(platform)
      end
    end
  end
end
