package com.tobykurien.webapps.fragment;

import android.app.Activity;
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
import com.tobykurien.webapps.WebAppActivity;

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
  
  public void onOpenUrlClick(final View v) {
    View _view = this.getView();
    View _findViewById = _view.findViewById(id.txtOpenUrl);
    EditText txtUrl = ((EditText) _findViewById);
    Activity _activity = this.getActivity();
    Intent _intent = new Intent(_activity, WebAppActivity.class);
    Intent i = _intent;
    i.setAction(Intent.ACTION_VIEW);
    Editable _text = txtUrl.getText();
    String _string = _text.toString();
    Uri _parse = Uri.parse(_string);
    i.setData(_parse);
    this.startActivity(i);
    this.dismiss();
  }
}
