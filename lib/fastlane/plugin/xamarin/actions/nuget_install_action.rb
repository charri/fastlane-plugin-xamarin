module Fastlane
  module Actions
    class NugetInstallAction < Action
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
        command.push("install")
        command.push(params[:config_file_path] || params[:package_id])
        command.push("-OutputDirectory") unless params[:output_directory].nil?
        command.push(params[:output_directory]) unless params[:output_directory].nil?

        command.push("-Verbosity")
        if FastlaneCore::Globals.verbose?
          command.push("detailed")
        else
          command.push("normal")
        end

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
          UI.error!("Uhh ohh - failed executing nuget")
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
          FastlaneCore::ConfigItem.new(key: :config_file_path,
                                       env_name: "NUGET_CONFIGFILEPATH",
                                       description: "Identifies the packages.config file that lists the packages to install",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :package_id,
                                       env_name: "NUGET_PACKAGEID",
                                       description: "The package to install (using the latest version)",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :nuget,
                                       env_name: "NUGET_PATH",
                                       description: "Path to `nuget`. Default value is found by using `which nuget`",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :output_directory,
                                       env_name: "NUGET_OUTPUT_DIRECTORY",
                                       description: "Specifies the folder in which packages are installed. If no folder is specified, the current folder is used",
                                       optional: true,
                                       type: String),
        ]

      end

      def self.is_supported?(platform)
        [:android, :ios].include?(platform)
      end
    end
  end
end
