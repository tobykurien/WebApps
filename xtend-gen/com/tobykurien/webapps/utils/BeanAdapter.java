package com.tobykurien.webapps.utils;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;
import com.google.common.base.Objects;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;
import org.eclipse.xtext.xbase.lib.CollectionLiterals;
import org.eclipse.xtext.xbase.lib.Conversions;
import org.eclipse.xtext.xbase.lib.Exceptions;
import org.eclipse.xtext.xbase.lib.Functions.Function0;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;
import org.eclipse.xtext.xbase.lib.ListExtensions;
import org.eclipse.xtext.xbase.lib.MapExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure2;

/**
 * Generic adapter to take data in the form of Java beans and use the getters
 * to get the data and apply to appropriately named views in the row layout, e.g.
 * getFirstName -> R.id.first_name
 * isToast -> R.id.toast
 */
@SuppressWarnings("all")
public class BeanAdapter<T extends Object> extends BaseAdapter {
  private final List<T> data;
  
  private final Context context;
  
  private final int layoutId;
  
  private final HashMap<Integer,Method> mapping = new Function0<HashMap<Integer,Method>>() {
    public HashMap<Integer,Method> apply() {
      HashMap<Integer,Method> _newHashMap = CollectionLiterals.<Integer, Method>newHashMap();
      return _newHashMap;
    }
  }.apply();
  
  public BeanAdapter(final Context context, final int layoutId, final List<T> data) {
    this.data = data;
    this.layoutId = layoutId;
    this.context = context;
  }
  
  public BeanAdapter(final Context context, final int layoutId, final T[] data) {
    final Function1<T,T> _function = new Function1<T,T>() {
        public T apply(final T i) {
          return i;
        }
      };
    List<T> _map = ListExtensions.<T, T>map(((List<T>)Conversions.doWrapArray(data)), _function);
    this.data = _map;
    this.layoutId = layoutId;
    this.context = context;
  }
  
  public int getCount() {
    int _length = ((Object[])Conversions.unwrapArray(this.data, Object.class)).length;
    return _length;
  }
  
  public T getItem(final int row) {
    T _get = this.data.get(row);
    return _get;
  }
  
  public long getItemId(final int row) {
    Long _xtrycatchfinallyexpression = null;
    try {
      Long _xblockexpression = null;
      {
        T item = this.getItem(row);
        Class<? extends Object> _class = item.getClass();
        Method m = _class.getMethod("getId");
        Object _invoke = m.invoke(item);
        String _valueOf = String.valueOf(_invoke);
        Long _valueOf_1 = Long.valueOf(_valueOf);
        _xblockexpression = (_valueOf_1);
      }
      _xtrycatchfinallyexpression = _xblockexpression;
    } catch (final Throwable _t) {
      if (_t instanceof Exception) {
        final Exception e = (Exception)_t;
        _xtrycatchfinallyexpression = Long.valueOf(((long) row));
      } else {
        throw Exceptions.sneakyThrow(_t);
      }
    }
    return (_xtrycatchfinallyexpression).longValue();
  }
  
  public View getView(final int row, final View cv, final ViewGroup root) {
    View _xblockexpression = null;
    {
      final T i = this.getItem(row);
      View v = cv;
      boolean _equals = Objects.equal(v, null);
      if (_equals) {
        LayoutInflater _from = LayoutInflater.from(this.context);
        View _inflate = _from.inflate(this.layoutId, root, false);
        v = _inflate;
        boolean _isEmpty = this.mapping.isEmpty();
        if (_isEmpty) {
          this.setupMapping(v, i);
        }
      }
      final View view = v;
      final Procedure2<Integer,Method> _function = new Procedure2<Integer,Method>() {
          public void apply(final Integer resId, final Method method) {
            try {
              View res = view.findViewById((resId).intValue());
              boolean _notEquals = (!Objects.equal(res, null));
              if (_notEquals) {
                Class<? extends View> _class = res.getClass();
                final Class<? extends View> _switchValue = _class;
                boolean _matched = false;
                if (!_matched) {
                  if (Objects.equal(_switchValue,TextView.class)) {
                    _matched=true;
                    Object _invoke = method.invoke(i);
                    String _valueOf = String.valueOf(_invoke);
                    ((TextView) res).setText(_valueOf);
                  }
                }
                if (!_matched) {
                  if (Objects.equal(_switchValue,EditText.class)) {
                    _matched=true;
                    Object _invoke_1 = method.invoke(i);
                    String _valueOf_1 = String.valueOf(_invoke_1);
                    ((EditText) res).setText(_valueOf_1);
                  }
                }
                if (!_matched) {
                  if (Objects.equal(_switchValue,ImageView.class)) {
                    _matched=true;
                    Object _invoke_2 = method.invoke(i);
                    ((ImageView) res).setImageBitmap(((Bitmap) _invoke_2));
                  }
                }
                if (!_matched) {
                  Class<? extends View> _class_1 = res.getClass();
                  String _plus = ("View type not yet supported: " + _class_1);
                  Log.e("base_adapter", _plus);
                }
              }
            } catch (Throwable _e) {
              throw Exceptions.sneakyThrow(_e);
            }
          }
        };
      MapExtensions.<Integer, Method>forEach(this.mapping, _function);
      _xblockexpression = (v);
    }
    return _xblockexpression;
  }
  
  /**
   * Set up the bean-to-view for use in subsequent rows
   */
  public void setupMapping(final View v, final T i) {
    Class<? extends Object> _class = i.getClass();
    Method[] _methods = _class.getMethods();
    final Procedure1<Method> _function = new Procedure1<Method>() {
        public void apply(final Method m) {
          boolean _or = false;
          String _name = m.getName();
          boolean _startsWith = _name.startsWith("get");
          if (_startsWith) {
            _or = true;
          } else {
            String _name_1 = m.getName();
            boolean _startsWith_1 = _name_1.startsWith("is");
            _or = (_startsWith || _startsWith_1);
          }
          if (_or) {
            String resName = BeanAdapter.this.toResourceName(m);
            Resources _resources = BeanAdapter.this.context.getResources();
            String _packageName = BeanAdapter.this.context.getPackageName();
            int resId = _resources.getIdentifier(resName, "id", _packageName);
            boolean _greaterThan = (resId > 0);
            if (_greaterThan) {
              BeanAdapter.this.mapping.put(Integer.valueOf(resId), m);
            }
          }
        }
      };
    IterableExtensions.<Method>forEach(((Iterable<Method>)Conversions.doWrapArray(_methods)), _function);
  }
  
  /**
   * Convert Java bean getter name into resource name format, i.e.
   * getFirstName -> first_name
   * isToast -> toast
   */
  public String toResourceName(final Method m) {
    String _xblockexpression = null;
    {
      String name = m.getName();
      String _name = m.getName();
      boolean _startsWith = _name.startsWith("get");
      if (_startsWith) {
        String _name_1 = m.getName();
        String _substring = _name_1.substring(3);
        name = _substring;
      } else {
        String _name_2 = m.getName();
        boolean _startsWith_1 = _name_2.startsWith("is");
        if (_startsWith_1) {
          String _name_3 = m.getName();
          String _substring_1 = _name_3.substring(2);
          name = _substring_1;
        }
      }
      String _replaceAll = name.replaceAll("(?=[\\p{Lu}])", "_");
      String _lowerCase = _replaceAll.toLowerCase();
      String _replaceAll_1 = _lowerCase.replaceAll("^_", "");
      _xblockexpression = (_replaceAll_1);
    }
    return _xblockexpression;
  }
}
