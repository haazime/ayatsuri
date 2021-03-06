require 'spec_helper'

shared_context "starter" do
	before do
		Ayatsuri::Driver.stub(:instance) { driver }
		driver.stub(:invoke)
	end
	let(:exe_path) { "/path/to/application.exe" }
	let(:driver) { mock 'driver instance' }
end

module Ayatsuri
	class Application
		describe Starter do
			include_context "starter"

			subject { described_class.create exe_path, starter_name }

			let(:starter_name) { :Fake }

			before do
				stub_const("Ayatsuri::Application::Starter::Fake", Class.new)
				Ayatsuri::Application::Starter::Fake.stub(:new).with(exe_path) { starter }
			end

			let(:starter) { mock 'application starter instance' }

			it { should == starter }
		end

		class Starter

			describe ProgramManager do
				include_context "starter"

				let(:model) { described_class.new exe_path }

				describe "#start" do
					subject { model.start }

					before do
						driver.stub(:window_exist?) { true }
						driver.stub(:window_active?) { false }
					end

					it { should be_true }
				end
			end

			describe Default do
				include_context "starter"

				let(:model) { described_class.new exe_path }

				describe "#start" do
					subject { model.start }

					before do
						driver.stub(:run_application).with(exe_path) { true }
					end

					it { should be_true }
				end
			end

			describe Wscript do
				include_context "starter"

				let(:model) { described_class.new exe_path }

				describe "#start" do
					subject { model.start }

					before do
						exe_path_obj = Pathname.new(exe_path)
						Dir.stub(:chdir).with(exe_path_obj.parent)
						WIN32OLE.stub(:new).with("WScript.Shell") { wscript_ole }
						wscript_ole.stub(:Run).with(exe_path_obj.basename) { true }
					end

					let(:wscript_ole) { mock 'WScript.Shell OLE' }

					it { should be_true }
				end
			end
		end
	end
end
