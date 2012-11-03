require 'spec_helper'

module Ayatsuri
	class Application
		describe Process do
			let(:model) { described_class.new starter, operator }

			let(:starter) { mock 'application starter' }
			let(:operator) { mock 'operator' }
			let(:dispatcher) { mock 'dispatcher' }

			describe "#run" do
				subject { model.run }

				it "calls start autmation process methods" do
					model.should_receive(:init_dispatcher).ordered
					model.should_receive(:start_application).ordered
					model.should_receive(:start_dispatch).ordered
					subject
				end
			end
			
			describe "#init_dispatcher" do
				subject { model.init_dispatcher }

				before do
					ActiveWindow::Change.stub(:init) { active_window }
					ActiveWindow::Dispatcher.stub(:new).with(active_window) { dispatcher }
				end

				let(:active_window) { mock 'active window' }

				it { should == dispatcher }
			end

			describe "#start_application" do
				subject { model.start_application }

				let(:stub_starter) { starter.stub(:start) }

				context "when successful" do
					before { stub_starter.and_return(true) }
					it { should be_true }
				end

				context "when failed" do
					before { stub_starter.and_raise(ex) }
					let(:ex) { Ayatsuri::FailedToRunApplication }
					it { expect { subject }.to raise_error ex }
				end
			end

			describe "#start_dispatch" do
				subject { model.start_dispatch }

				before do
					model.stub(:dispatcher) { dispatcher }
					model.stub(:operator) { operator }
				end

				let(:stub_dispatch) { dispatcher.stub(:start).with(operator) }

				context "when successful" do
					before { stub_dispatch.and_return(true) }
					it { should be_true }
				end

				context "when failed" do
					before { stub_dispatch.and_raise(ex) }
					let(:ex) { AyatsuriError }

					it "raise exception before quit application" do
						operator.should_receive(:quit_application)
						expect { subject }.to raise_error(ex)
					end
				end
			end
		end
	end
end