package com.tobykurien.webapps.fragment;

import android.app.Activity;
import android.app.Dialog;
import android.app.DialogFragment;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Editable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import com.tobykurien.webapps.R.id;
import com.tobykurien.webapps.R.layout;
import com.tobykurien.webapps.R.string;
import com.tobykurien.webapps.WebAppActivity;
import com.tobykurien.xtendroid.utils.AlertUtils;
import org.eclipse.xtext.xbase.lib.Exceptions;

@SuppressWarnings("all")
public class DlgOpenUrl extends DialogFragment {
  public View onCreateView(final LayoutInflater inflater, final ViewGroup container, final Bundle savedInstanceState) {
    View _xblockexpression = null;
    {
      View v = inflater.inflate(layout.dlg_open_url, container, false);
      View _findViewById = v.findViewById(id.btnOpenUrl);
      Button b = ((Button) _findViewById);
      final OnClickListener _function = new OnClickListener() {
        public void onClick(final View btn) {
          DlgOpenUrl.this.onOpenUrlClick(btn);
        }
      };
      b.setOnClickListener(_function);
      _xblockexpression = (v);
    }
    return _xblockexpression;
  }
  
  public void onStart() {
    super.onStart();
    Dialog _dialog = this.getDialog();
    String _string = this.getString(string.open_site);
    _dialog.setTitle(_string);
  }
  
  public void onOpenUrlClick(final View v) {
    View _view = this.getView();
    View _findViewById = _view.findViewById(id.txtOpenUrl);
    EditText txtUrl = ((EditText) _findViewById);
    Activity _activity = this.getActivity();
    Intent _intent = new Intent(_activity, WebAppActivity.class);
    Intent i = _intent;
    i.setAction(Intent.ACTION_VIEW);
    try {
      Editable _text = txtUrl.getText();
      String _string = _text.toString();
      String _plus = ("https://" + _string);
      Uri _parse = Uri.parse(_plus);
      i.setData(_parse);
      this.startActivity(i);
      this.dismiss();
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        Activity _activity_1 = this.getActivity();
        String _message = e.getMessage();
        String _plus_1 = ("Error parsing URL: " + _message);
        AlertUtils.toast(_activity_1, _plus_1);
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
  }
}
