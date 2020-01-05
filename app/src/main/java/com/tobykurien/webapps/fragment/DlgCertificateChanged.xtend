package com.tobykurien.webapps.fragment

import android.net.http.SslCertificate
import com.tobykurien.webapps.data.Webapp
import org.xtendroid.annotations.AndroidDialogFragment
import com.tobykurien.webapps.R
import org.xtendroid.app.OnCreate
import android.os.Bundle
import android.support.v7.app.AlertDialog
import com.tobykurien.webapps.db.DbService

import static extension com.tobykurien.webapps.utils.Dependencies.*
import static extension org.xtendroid.utils.AlertUtils.*

@AndroidDialogFragment(R.layout.dlg_certificate_changed) class DlgCertificateChanged extends DlgCertificate {
    var Webapp webapp = null

    public new(Webapp webapp, SslCertificate certificate, String title, String okText,
        ()=>boolean onOkClicked, ()=>boolean onCancelClicked) {
        super(certificate, title, okText, onOkClicked, onCancelClicked)
        this.webapp = webapp
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
                if (okText == null) getString(android.R.string.ok) else okText, [ 
                    if (onOkClicked != null) onOkClicked.apply() 
                ]) // to avoid it closing dialog
            .setNegativeButton(android.R.string.cancel, [
                if (onCancelClicked != null) onCancelClicked.apply()
            ])
            .setNeutralButton(R.string.btn_disable_cert_checks, [
                // Allow user to permanently disable certificate checks
                activity.confirm(getString(R.string.confirm_cert_disable)) [
                    webapp.ignoreCertChanges = true
                    if (webapp.id > 0) activity.db.update(DbService.TABLE_WEBAPPS, #{
                        'ignoreCertChanges' -> webapp.ignoreCertChanges
                    }, webapp.id)
                ]
            ])
            .create()
    }

    @OnCreate
    override init() {
        issuedBy1.text = webapp.certIssuedBy.formatDname
        issuedTo1.text = webapp.certIssuedTo.formatDname
        expires1.text = webapp.certValidFrom + " to \n" + webapp.certValidTo

        issuedBy2.text = certificate.issuedBy.DName.formatDname
        issuedTo2.text = certificate.issuedTo.DName.formatDname
        expires2.text = certificate.validNotBeforeDate.toLocaleString + " to \n" +
                certificate.validNotAfterDate.toLocaleString
    }

}