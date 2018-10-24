module Fastlane
  module Actions
   

    class NugetRestoreAction < Action
      def self.run(params)
        
        nuget = params[:nuget] || FastlaneCore::CommandExecutor.which('nuget')

        if nuget.nil?
            UI.error("Could not find nuget")
            return
        end

        if FastlaneCore::Globals.verbose?
          FastlaneCore::PrintTable.print_values(
            config: params,
            title: "Summary of parameters passed"
          )
        end        
        command = Array.new

        command.push(nuget)
        command.push("restore")
        command.push(params[:project_path])
        command.push("-NonInteractive")

        exit_status = 0
        result = FastlaneCore::CommandExecutor.execute(command: command,
                                        print_command: true,
                                        print_all: FastlaneCore::Globals.verbose?,
                                        error: proc do |error_output|
                                          exit_status = $?.exitstatus
                                        end)

        if exit_status == 0
          UI.success("Successfully executed nuget")
        else
          UI.user_error!("Uhh ohh - failed executing nuget")
        end
        

      end

      def self.description
        "Nuget"
      end

      def self.authors
        ["Thomas Charriere"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        "Nuget restore"
      end


      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project_path,
                                       env_name: "NUGET_SOLUTION",
                                       description: "The location of a solution or a packages.config",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :nuget,
                                       env_name: "NUGET_PATH",
                                       description: "Path to `nuget`. Default value is found by using `which nuget`",
                                       optional: true,
                                       type: String)
        ]

      end

      def self.is_supported?(platform)
        [:android, :ios].include?(platform)
      end
    end
  end
end
