module Ayatsuri
	class Driver
		module ModifierMethods
			include EncodeHelper

			def input(stuff)
				modify(:Send, stuff)
			end

			def activate_window(window_title)
				modify(:WinActivate, [window_title])
			end

			def close_window(window_title)
				modify(:WinClose, [window_title])
			end

			def focus_control(window_title, control_id)
				modify(:ControlFocus, [window_title, "", control_id])
			end

			def click_control(window_title, control_id)
				modify(:ControlClick, [window_title, "", control_id])
			end

			def set_text_to_control(window_title, control_id, text)
				modify(:ControlSetText, [window_title, "", control_id, text])
			end

			def select_tree_view_item(window_title, control_id, item_no)
				modify(:ControlTreeView, [window_title, "", control_id, "Select", "##{item_no}", ""])
			end

			def click_coordinate(button, x, y, clicks)
				modify(:MouseClick, [button, x, y, clicks])
			end

		private

			def modify(method, args)
				invoke(method, encode_for_driver(args))
			end
		end
	end
end
