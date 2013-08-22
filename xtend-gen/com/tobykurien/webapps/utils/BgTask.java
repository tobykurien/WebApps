package com.tobykurien.webapps.utils;

import android.app.ProgressDialog;
import android.os.AsyncTask;
import com.google.common.base.Objects;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;

/**
 * Convenience class to run tasks in the background using AsyncTask.
 * The generic paramater is the type of the result from the background task to
 * be passed into the UI task
 */
@SuppressWarnings("all")
public class BgTask<R extends Object> extends AsyncTask<Void,Void,R> {
  private Function0<R> bgFunction;
  
  private Function1<R,Void> uiFunction;
  
  private ProgressDialog pd;
  
  public AsyncTask<Void,Void,R> runInBgWithProgress(final ProgressDialog pdialog, final Function0<R> bg, final Function1<R,Void> ui) {
    AsyncTask<Void,Void,R> _xblockexpression = null;
    {
      this.pd = pdialog;
      AsyncTask<Void,Void,R> _runInBg = this.runInBg(bg, ui);
      _xblockexpression = (_runInBg);
    }
    return _xblockexpression;
  }
  
  public AsyncTask<Void,Void,R> runInBg(final Function0<R> bg, final Function1<R,Void> ui) {
    AsyncTask<Void,Void,R> _xblockexpression = null;
    {
      this.bgFunction = bg;
      this.uiFunction = ui;
      boolean _and = false;
      boolean _notEquals = (!Objects.equal(this.pd, null));
      if (!_notEquals) {
        _and = false;
      } else {
        boolean _isShowing = this.pd.isShowing();
        boolean _not = (!_isShowing);
        _and = (_notEquals && _not);
      }
      if (_and) {
        this.pd.show();
      }
      AsyncTask<Void,Void,R> _xtrycatchfinallyexpression = null;
      try {
        AsyncTask<Void,Void,R> _execute = this.execute();
        _xtrycatchfinallyexpression = _execute;
      } finally {
        this.dismissProgress();
      }
      _xblockexpression = (_xtrycatchfinallyexpression);
    }
    return _xblockexpression;
  }
  
  protected R doInBackground(final Void... arg0) {
    return this.bgFunction.apply();
  }
  
  protected void onPostExecute(final R result) {
    try {
      boolean _notEquals = (!Objects.equal(this.uiFunction, null));
      if (_notEquals) {
        this.uiFunction.apply(result);
      }
    } finally {
      this.dismissProgress();
    }
  }
  
  public void dismissProgress() {
    boolean _notEquals = (!Objects.equal(this.pd, null));
    if (_notEquals) {
      this.pd.dismiss();
    }
  }
}
