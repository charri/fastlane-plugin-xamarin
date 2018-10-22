module Fastlane
  module Actions
    module SharedValues
      XAMARIN_ANDROID_APK = :XAMARIN_ANDROID_APK
      XAMARIN_ANDROID_APK_SIGNED = :XAMARIN_ANDROID_APK_SIGNED
    end

    class XamarinAndroidAction < Action
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
        command.push("/p:DebugSymbols=#{params[:debug_symbols]}") unless params[:debug_symbols].nil?
        command.push("/p:DebugType=#{params[:debug_type]}") unless params[:debug_type].nil?
        command.push("/p:AndroidSupportedAbis=#{params[:android_supported_abis]}") unless params[:android_supported_abis].nil?
        command.push("/p:AndroidUseSharedRuntime=#{params[:android_use_sharedruntime]}") unless params[:android_use_sharedruntime].nil?
        command.push("/p:AotAssemblies=#{params[:android_aot_assemblies]}") unless params[:android_aot_assemblies].nil?
        command.push("/p:EnableLLVM=#{params[:android_enable_llvm]}") unless params[:android_enable_llvm].nil?
        command.push("/p:EnableProguard=#{params[:android_enable_proguard]}") unless params[:android_enable_proguard].nil?
        command.push("/p:AndroidKeyStore=#{params[:android_keystore]}") unless params[:android_keystore].nil?
        command.push("/p:AndroidSigningKeyAlias=#{params[:android_signing_keyalias]}") unless params[:android_signing_keyalias].nil?
        command.push("/p:AndroidSigningKeyPass=#{params[:android_signing_keypass]}") unless params[:android_signing_keypass].nil?
        command.push("/p:AndroidSigningKeyStore=#{params[:android_signing_keystore]}") unless params[:android_signing_keystore].nil?
        command.push("/p:AndroidSigningStorePass=#{params[:android_signing_storepass]}") unless params[:android_signing_storepass].nil?

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

          Dir.glob(File.join(File.dirname(params[:project]), "/**/bin/#{params[:configuration]}/*.apk")) {|file|

            if file.include? "Signed"
              Actions.lane_context[SharedValues::XAMARIN_ANDROID_APK_SIGNED] = file
              Actions.lane_context[SharedValues::GRADLE_APK_OUTPUT_PATH] = file
            else
              Actions.lane_context[SharedValues::XAMARIN_ANDROID_APK] = file
            end

          }

          FastlaneCore::PrintTable.print_values(
            config: Actions.lane_context,
            title: "Summary of Xamarin Build"
          )

        else
          UI.error("Unable to build - see log for more info")
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
          ['XAMARIN_ANDROID_APK', 'Path to the apk'],
          ['XAMARIN_ANDROID_APK_SIGNED', 'Path to the signed apk']
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :project,
                                       env_name: "XAMARIN_PROJECT",
                                       description: "Path to Android Project (.csproj) to compile",
                                       optional: false,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :target,
                                       env_name: "XAMARIN_TARGET",
                                       description: "Specifies the Build Targets: Build, SignAndroidPackage",
                                       default_value: 'SignAndroidPackage',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :configuration,
                                       env_name: "XAMARIN_CONFIGURATION",
                                       description: "Specifies the build configuration to use, such as 'Debug' or 'Release'. The Configuration property is used to determine default values for other properties which determine target behavior. Additional configurations may be created within your IDE",
                                       default_value: 'Release',
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :msbuild,
                                       env_name: "XAMARIN_MSBUILD",
                                       description: "Path to `msbuild`. Default value is found by using `which msbuild`",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :debug_symbols,
                                       env_name: "XAMARIN_DEBUGSYMBOLS",
                                       description: "A boolean value which determines whether the Android package is debuggable, in combination with the `debug_type` option. A debuggable package contains debug symbols, sets the `//application/@android:debuggable` attribute to true, and automatically adds the INTERNET permission so that a debugger can attach to the process. An application is debuggable if `debug_symbols` is True and `debug_type` is either the empty string or Full",
                                       optional: true,
                                       type: Fastlane::Boolean),

          FastlaneCore::ConfigItem.new(key: :debug_type,
                                       env_name: "XAMARIN_DEBUGTYPE",
                                       description: "Specifies the type of debug symbols to generate as part of the build, which also impacts whether the Application is debuggable. Possible values include: Full, PdbOnly",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :define_constants,
                                       env_name: "XAMARIN_DEFINECONSTANTS",
                                       description: "Defines conditional compiler constants",
                                       optional: true,
                                       type: String),

          FastlaneCore::ConfigItem.new(key: :android_supported_abis,
                                       env_name: "XAMARIN_ANDROIDSUPPORTEDABIS",
                                       description: "A string property that contains a semicolon (;)-delimited list of ABIs which should be included into the .apk: armeabi, armeabi-v7a, x86, arm64-v8a, x86_64",
                                       optional: true,
                                       type: String), 

          FastlaneCore::ConfigItem.new(key: :android_use_sharedruntime,
                                       env_name: "XAMARIN_ANDROIDUSESHAREDRUNTIME",
                                       description: "A boolean property that is determines whether the shared runtime packages are required in order to run the Application on the target device. Relying on the shared runtime packages allows the Application package to be smaller, speeding up the package creation and deployment process, resulting in a faster build/deploy/debug turnaround cycle. This property should be True for Debug builds, and False for Release projects",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :android_aot_assemblies,
                                       env_name: "XAMARIN_ANDROIDAOTASSEMBLIES",
                                       description: "A boolean property that determines whether or not assemblies will be Ahead-of-Time compiled into native code and included in the .apk",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :android_enable_llvm,
                                       env_name: "XAMARIN_ANDROIDENABLELLVM",
                                       description: "A boolean property that determines whether or not LLVM will be used when Ahead-of-Time compiling assemblies into native code",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :android_enable_proguard,
                                       env_name: "XAMARIN_ANDROIDENABLEPROGUARD",
                                       description: "A boolean property that determines whether or not proguard is run as part of the packaging process to link Java code",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :android_keystore,
                                       env_name: "XAMARIN_ANDROIDKEYSTORE",
                                       description: "A boolean value which indicates whether custom signing information should be used. The default value is False, meaning that the default debug-signing key will be used to sign packages",
                                       optional: true,
                                       type: Fastlane::Boolean), 

          FastlaneCore::ConfigItem.new(key: :android_signing_keystore,
                                       env_name: "XAMARIN_ANDROIDSIGNINGKEYSTORE",
                                       description: "Specifies the alias for the key in the keystore. This is the keytool -alias value used when creating the keystore",
                                       optional: true,
                                       type: String), 

          FastlaneCore::ConfigItem.new(key: :android_signing_storepass,
                                       env_name: "XAMARIN_ANDROIDSIGNINGSTOREPASS",
                                       description: "Specifies the password of the keystore file",
                                       optional: true,
                                       type: String), 

          FastlaneCore::ConfigItem.new(key: :android_signing_keyalias,
                                       env_name: "XAMARIN_ANDROIDSINGINGKEYALIAS",
                                       description: "Specifies the filename of the keystore file created by keytool",
                                       optional: true,
                                       type: String), 

          FastlaneCore::ConfigItem.new(key: :android_signing_keypass,
                                       env_name: "XAMARIN_ANDROIDSIGNINGKEYPASS",
                                       description: "Specifies the password of the key within the keystore file",
                                       optional: true,
                                       type: String)
        ]

      end

      def self.is_supported?(platform)
        [:android].include?(platform)
      end
    end
  end
end
