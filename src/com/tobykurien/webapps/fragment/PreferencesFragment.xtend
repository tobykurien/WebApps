package com.tobykurien.webapps.fragment

import android.preference.PreferenceFragment
import android.os.Bundle
import com.tobykurien.webapps.R

class PreferencesFragment extends PreferenceFragment {
   
   override onActivityCreated(Bundle savedInstanceState) {
      super.onActivityCreated(savedInstanceState)
      addPreferencesFromResource(R.xml.settings)
   }
   
}