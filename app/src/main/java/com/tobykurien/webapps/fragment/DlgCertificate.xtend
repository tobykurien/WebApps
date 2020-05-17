package com.tobykurien.webapps.fragment

import android.os.Bundle
import android.support.v7.app.AlertDialog
import org.xtendroid.annotations.AndroidDialogFragment
import org.xtendroid.app.OnCreate
import android.support.v4.app.DialogFragment
import com.tobykurien.webapps.R
import android.net.http.SslCertificate

@AndroidDialogFragment(R.layout.dlg_certificate) class DlgCertificate extends DialogFragment {
	var protected SslCertificate certificate = null
	var protected String title = null
	var protected String okText = null
	var protected ()=>boolean onOkClicked = null
	var protected ()=>boolean onCancelClicked = null

	public new(SslCertificate certificate, String title, String okText,
		()=>boolean onOkClicked, ()=>boolean onCancelClicked) {
		this.certificate = certificate
		this.title = title
		this.okText = okText
		this.onOkClicked = onOkClicked
		this.onCancelClicked = onCancelClicked
	}

	public new(SslCertificate certificate) {
		this.certificate = certificate
	}
	
	/**
	 * Create a dialog using the AlertDialog Builder, but our custom layout
	 */
	override onCreateDialog(Bundle instance) {
		if (title == null) title = getString(R.string.title_certificate)
		
		new AlertDialog.Builder(activity)
			.setTitle(title)
			.setView(contentView) // contentView is the layout specified in the annotation
			.setPositiveButton(
				if (okText == null) getString(android.R.string.ok) else okText, 
				[ if (onOkClicked != null) onOkClicked.apply() ]) // to avoid it closing dialog
			.setNegativeButton(android.R.string.cancel, [
				if (onCancelClicked != null) onCancelClicked.apply()
			])
			.create()
	}

	@OnCreate
	def init() {
		issuedBy.text = certificate.issuedBy.DName.formatDname
		issuedTo.text = certificate.issuedTo.DName.formatDname
		expires.text = certificate.validNotBeforeDate.toLocaleString + " to \n" +
			certificate.validNotAfterDate.toLocaleString
	}
	
	def static formatDname(String DName) {
		DName.replace("\\,", " ").split(",").join("\n")
	}
}
