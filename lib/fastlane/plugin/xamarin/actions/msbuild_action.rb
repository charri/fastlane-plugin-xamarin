module Fastlane
  module Actions

    class MsbuildAction < Action
      def self.run(params)
        
        msbuild = params[:msbuild] || FastlaneCore::CommandExecutor.which('msbuild')

        if msbuild.nil?
            UI.error("Could not find msbuild")
            return
        end

        if FastlaneCore::Globals.verbose?
          FastlaneCore::PrintTable.print_values(
            config: params,
            title: "Summary of parameters passed"
          )
        end        
        command = Array.new

        command.push(msbuild)
        command.push(params[:project])
        command.push("/t:#{params[:target]}")
        command.push("/p:Configuration=#{params[:configuration]}") unless params[:configuration].nil?
        command.push("/p:DefineConstants=#{params[:define_constants]}") unless params[:define_constants].nil?
        command.push("/p:DebugType=#{params[:debug_type]}") unless params[:debug_type].nil?

        if FastlaneCore::Globals.verbose?
          command.push("/v:d")
        else
          command.push("/v:m")
        end

        
        exit_status = 0
        result = FastlaneCore::CommandExecutor.execute(command: command,
                                        print_command: true,
                                        print_all: FastlaneCore::Globals.verbose?,
                                        error: proc do |error_output|
                                          exit_status = $?.exitstatus
                                          UI.error("Wups, invalid")
                                        end)

        if exit_status == 0
          UI.success("Successfully executed msbuild")
        else
          UI.error!("Unable to build - see log for more info")
        end
        

      end

      def self.description
        "Build Solutions with msbuild"
      end

      def self.authors
        ["Thomas Charriere"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Build Solutions with msbuild"
      end

      def self.output
        [
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "MSBUILD_SOLUTION",
                                       description: "Path to Solution (.sln) to compile",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "MSBUILD_TARGET",
                                       description: "Specifies the Build Targets: Build",
                                       default_value: 'Build',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "MSBUILD_CONFIGURATION",
                                       description: "Specifies the build configuration to use, such as 'Debug' or 'Release'. The Configuration property is used to determine default values for other properties which determine target behavior. Additional configurations may be created within your IDE",
                                       default_value: 'Release',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :msbuild,
                                       env_name: "MSBUILD_MSBUILD",
                                       description: "Path to `msbuild`. Default value is found by using `which msbuild`",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :debug_type,
                                       env_name: "MSBUILD_DEBUGTYPE",
                                       description: "Specifies the type of debug symbols to generate as part of the build, which also impacts whether the Application is debuggable. Possible values include: Full, PdbOnly",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :define_constants,
                                       env_name: "MSBUILD_DEFINECONSTANTS",
                                       description: "Defines conditional compiler constants",
                                       optional: true,
                                       type: String)
        ]

      end

      def self.is_supported?(platform)
        [:android, :ios, :mac].include?(platform)
      end
    end
  end
end
