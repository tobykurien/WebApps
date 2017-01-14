package com.tobykurien.webapps.fragment

import android.os.Bundle
import android.support.v7.app.AlertDialog
import org.xtendroid.annotations.AndroidDialogFragment
import org.xtendroid.app.OnCreate
import android.support.v4.app.DialogFragment
import com.tobykurien.webapps.R
import android.net.http.SslCertificate

@AndroidDialogFragment(R.layout.dlg_certificate) class DlgCertificate extends DialogFragment {
	var SslCertificate certificate = null
	var String okText = null
	var ()=>boolean onOkClicked = null
	
	public new(SslCertificate certificate, String okText, ()=>boolean onOkClicked) {
		this.certificate = certificate
		this.okText = okText
		this.onOkClicked = onOkClicked
	}
	
	public new(SslCertificate certificate) {
		this.certificate = certificate
	}
	
	/**
	 * Create a dialog using the AlertDialog Builder, but our custom layout
	 */
	override onCreateDialog(Bundle instance) {
		new AlertDialog.Builder(activity)
			.setTitle(com.tobykurien.webapps.R.string.title_certificate)
			.setView(contentView) // contentView is the layout specified in the annotation
			.setPositiveButton(
				if (okText == null) getString(android.R.string.ok) else okText, 
				[ if (onOkClicked != null) onOkClicked.apply() ]) // to avoid it closing dialog
			.setNegativeButton(android.R.string.cancel, null)
			.create()
	}

	@OnCreate
	def init() {
		content.text = certificate.toString
	}
}
