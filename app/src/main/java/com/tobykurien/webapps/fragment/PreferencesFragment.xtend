package com.tobykurien.webapps.fragment

import android.app.AlertDialog
import android.content.Context
import android.os.Bundle
import android.preference.Preference
import android.preference.Preference.OnPreferenceChangeListener
import android.preference.PreferenceFragment
import android.widget.EditText
import com.tobykurien.webapps.R

import static extension com.tobykurien.webapps.utils.Settings.*

class PreferencesFragment extends PreferenceFragment {

	override onActivityCreated(Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState)
		addPreferencesFromResource(R.xml.settings)
		
		
		val uaPref = preferenceManager.findPreference("user_agent")
		uaPref.summary = settings.userAgent.showUA

		uaPref.onPreferenceChangeListener = new OnPreferenceChangeListener() {
			override onPreferenceChange(Preference pref, Object value) {
				val ua = value as String
				if (ua == "Custom") {
					// ask user for custom user agent
					activity.promptUA [ newUA |
						uaPref.summary = newUA.showUA
						pref.editor.putString("user_agent", newUA).commit()										
					]
				} else {
					uaPref.summary = ua.showUA
					pref.editor.putString("user_agent", ua).commit()				
				}
				
				true
			}
			
		}
	}
	
	def static promptUA(Context context, (String)=>void proc) {
		val inputField = new EditText(context)
		
		new AlertDialog.Builder(context)
			.setTitle(R.string.menu_user_agent)
			.setView(inputField)
			.setPositiveButton(android.R.string.ok, [ dlg, i |
				proc.apply(inputField.text.toString())
				dlg.dismiss
			])
			.create()
			.show()							
	}
	
	def showUA(String ua) {
		if (ua.trim().length() == 0) {
			"Default"
		} else {
			ua
		}
	}

}
