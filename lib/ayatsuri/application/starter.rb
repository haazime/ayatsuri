#encoding:utf-8

require 'win32ole'
require 'pathname'

module Ayatsuri
	class Application
		class Starter

			class Base

				def initialize(exe_path)
					@exe_path = exe_path
				end

				def start
					raise StandardError, "'start` is not implemented for #{self.class}"
				end

			protected

				def driver
					Driver.instance
				end
			end
			
			class Default < Base

				def start
					driver.run_application(@exe_path)
					true
				end
			end

			class Wscript < Base
				include Driver::EncodeHelper

				def start
					Dir.chdir(application_exe_dir) do
						wscript_ole.Run(application_exe)
					end
					true
				end

			private

				def wscript_ole
					WIN32OLE.new("WScript.Shell")
				end

				def application_exe_path
					@application_exe_path ||= Pathname.new(@exe_path)
				end

				def application_exe_dir
					application_exe_path.parent
				end

				def application_exe
					application_exe_path.basename.to_s
				end
			end

			class ProgramManager < Base
				include Waitable

				@window_title = 'ファイル名を指定して実行'

				class << self
					attr_accessor :window_title
				end

				def start
					driver.invoke(:Send, "#r")
					wait_until(3, "open win + r") { driver.window_exist?(self.class.window_title) }
					driver.invoke(:Send, "#{@exe_path}")
					sleep 2
					driver.invoke(:Send, "{ENTER}")
					wait_until(3, "close win + r") { !driver.window_active?(self.class.window_title) }
					true
				end
			end

			class << self

				def create(exe_path, starter_name)
					starter_class = const_get(starter_name.to_s)
					starter_class.new(exe_path)
				end
			end
		end
	end
end
