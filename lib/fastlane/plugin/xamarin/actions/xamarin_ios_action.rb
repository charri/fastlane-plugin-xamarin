module Fastlane
  module Actions
    module SharedValues
      XAMARIN_IOS_IPA = :XAMARIN_IOS_IPA
      XAMARIN_IOS_SYM = :XAMARIN_IOS_SYM
    end

    class XamarinIosAction < Action
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
        command.push(params[:solution])
        command.push("/t:#{params[:target]}")
        command.push("/p:Configuration=#{params[:configuration]}") unless params[:configuration].nil?
        command.push("/p:Platform=#{params[:platform]}") unless params[:platform].nil?
        command.push("/p:DefineConstants=#{params[:define_constants]}") unless params[:define_constants].nil?
        command.push("/p:BuildIpa=#{params[:build_ipa]}") unless params[:build_ipa].nil?
        command.push("/p:IpaPackageDir=#{params[:ipa_package_dir]}") unless params[:ipa_package_dir].nil?
        command.push("/p:CodesignEntitlements=#{params[:codesign_entitlements]}") unless params[:codesign_entitlements].nil?
        command.push("/p:IpaIncludeArtwork=#{params[:include_itunes_artwork]}") unless params[:include_itunes_artwork].nil?
        command.push("/p:CodesignKey=#{params[:codesign_key]}") unless params[:codesign_key].nil?
        command.push("/p:CodesignProvision=#{params[:codesign_provision]}") unless params[:codesign_provision].nil?

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

          if params[:ipa_package_dir].nil?

          end

          Dir.glob(File.join(File.dirname(params[:solution]), "/**/bin/#{params[:platform]}/#{params[:configuration]}/*.ipa")) {|file|

            Actions.lane_context[SharedValues::XAMARIN_IOS_IPA] = file
            Actions.lane_context[SharedValues::IPA_OUTPUT_PATH] = file
          }

          Dir.glob(File.join(File.dirname(params[:solution]), "/**/bin/#{params[:platform]}/#{params[:configuration]}/*.dSYM")) {|file|

            zipfile = file + ".zip"

            File.delete(zipfile) if File.exist?(zipfile)

            Actions::ZipAction.run(path: file, output_path:  zipfile)
            Actions.lane_context[SharedValues::XAMARIN_IOS_SYM] = zipfile
            Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH] = zipfile

          }

          FastlaneCore::PrintTable.print_values(
            config: Actions.lane_context,
            title: "Summary of Xamarin Build"
          )

        else
          UI.error!("Unable to build - see log for more info")
        end
        

      end

      def self.description
        "Build Xamarin Android + iOS projects"
      end

      def self.authors
        ["Thomas Charriere"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Build Xamarin Android + iOS projects"
      end

      def self.output
        [
          ['XAMARIN_IOS_IPA', 'Path to the ipa'],
          ['XAMARIN_IOS_SYM', 'Path to the dysm of the ipa']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :solution,
                                       env_name: "XAMARIN_SOLUTION",
                                       description: "Path to Solution to compile",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "XAMARIN_TARGET",
                                       description: "Specifies the Build Targets: Build",
                                       default_value: 'Build',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "XAMARIN_CONFIGURATION",
                                       description: "Specifies the build configuration to use, such as 'Debug' or 'Release'. The Configuration property is used to determine default values for other properties which determine target behavior. Additional configurations may be created within your IDE",
                                       default_value: 'Release',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :platform,
                                       env_name: "XAMARIN_PLATFORM",
                                       description: "Specifies the platform configuration to use, such as 'iPhone' or 'iPhoneSimulator'. The Platform property is used to determine default values for other properties which determine target behavior. Additional configurations may be created within your IDE",
                                       default_value: 'iPhone',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :define_constants,
                                       env_name: "XAMARIN_DEFINECONSTANTS",
                                       description: "Defines conditional compiler constants",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :msbuild,
                                       env_name: "XAMARIN_MSBUILD",
                                       description: "Path to `msbuild`. Default value is found by using `which msbuild`",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :build_ipa,
                                       env_name: "XAMARIN_BUILDIPA",
                                       description: "A boolean value which determines whether the ipa should be built",
                                       default_value: true,
                                       optional: true,
                                       type: Fastlane::Boolean),

          FastlaneCore::ConfigItem.new(key: :ipa_package_dir,
                                       env_name: "XAMARIN_IPAPACKAGEDIR",
                                       description: "Set custom IPA directory",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :codesign_entitlements,
                                       env_name: "XAMARIN_CODESIGNENTITLEMENTS",
                                       description: "",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :include_itunes_artwork,
                                       env_name: "XAMARIN_INCLUDEITUNESARTWORK",
                                       description: "Includes ITunesArtwork images",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :codesign_key,
                                       env_name: "XAMARIN_CODESIGNKEY",
                                       description: "A signing identity",
                                       optional: true,  
                                       type: String), 

          FastlaneCore::ConfigItem.new(key: :codesign_provision,
                                       env_name: "XAMARIN_CODESIGNPROVISION",
                                       description: "Id/Name of the provisioning profile",
                                       optional: true,
                                       type: String)
        ]

      end

      def self.is_supported?(platform)
        [:ios].include?(platform)
      end
    end
  end
end
