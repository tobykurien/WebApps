package asia.sonix.android.orm;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.database.Cursor;
import android.database.SQLException;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;
import android.util.Log;

/**
 * Android向けのO/RMを提供します。
 * 
 * @author sonix - http://www.sonix.asia
 * @since JDK1.5 Android Level 3
 * 
 */
public class AbatisService extends SQLiteOpenHelper {
   /**
    * Debug TAG名
    */
   private static final String TAG = "aBatis";

   /**
    * DBを初期化するSQLID
    */
   private static final String INIT_CREATE_SQL = "initialize";
   /**
    * Default DB file name
    */
   private static final String DB_FILE_NAME = "database.db";

   /**
    * 自分のinstance object
    */
   private static AbatisService instance = null;

   /**
    * SQLiteDatabase object
    */
   private SQLiteDatabase dbObj;

   /**
    * Context object
    */
   private Context context;

   /**
    * Default DB file nameを利用するConstructor
    * 
    * @param context
    *           呼び出し元Contextオブジェクト
    * 
    */
   protected AbatisService(Context context, int version) {
      super(context, DB_FILE_NAME, null, version);
      this.context = context;
   }

   /**
    * 指定DB file nameを利用するConstructor
    * 
    * @param context
    *           呼び出し元Contextオブジェクト
    * @param dbName
    *           生成するDB file name
    * 
    */
   protected AbatisService(Context context, String dbName, int version) {
      super(context, dbName.concat(".db"), null, version);
      this.context = context;
   }

   /**
    * Default DB file nameを利用する外部Constructor
    * 
    * @param context
    *           呼び出し元Contextオブジェクト
    * @param dbName
    *           生成するDB file name
    * 
    */
   protected static AbatisService getInstance(Context context, int version) {
      if (instance == null) {
         instance = new AbatisService(context, version);
      }
      return instance;
   }

   /**
    * 指定DB file nameを利用する外部Constructor
    * 
    * @param context
    *           呼び出し元Contextオブジェクト
    * @param dbName
    *           生成するDB file name
    * 
    */
   protected static AbatisService getInstance(Context context, String dbName, int version) {
      if (instance == null) {
         instance = new AbatisService(context, dbName, version);
      }
      return instance;
   }

   /**
    * DB connector
    * 
    * @param db
    *           SQLiteDatabase object
    * 
    */
   @Override
   public void onCreate(SQLiteDatabase db) {
      int pointer = context.getResources().getIdentifier(INIT_CREATE_SQL, "string", context.getPackageName());
      if (pointer == 0) {
         Log.e(TAG, "undefined sql id - initialize");
      } else {
         String createTabelSql = context.getResources().getString(pointer);
         for (String sql : createTabelSql.split(";")) {
            db.execSQL(sql);
         }
      }
   }

   /**
    * for upgrade (バージョン0.1では実装されていない)
    * 
    * @param db
    *           SQLiteDatabase object
    * @param oldVersion
    *           old version value
    * @param newVersion
    *           new version value
    * 
    */
   @Override
   public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
      // no poc
   }

   /**
    * 指定したSQLIDにparameterをmappingして、クエリする。結果mapを返却。
    * 
    * <p>
    * mappingの時、parameterが足りない場合はnullを返す。 また、結果がない場合nullを返す。
    * </p>
    * 
    * @param sqlId
    *           SQLID
    * @param bindParams
    *           sql parameter
    * 
    * @return Map<String, Object> result
    */
   public Map<String, Object> executeForMap(int sqlId, Map<String, ? extends Object> bindParams) {
      getDbObject();
      try {
         String sql = context.getResources().getString(sqlId);
         if (bindParams != null) {
            Iterator<String> mapIterator = bindParams.keySet().iterator();
            while (mapIterator.hasNext()) {
               String key = mapIterator.next();
               Object value = bindParams.get(key);
               sql = sql.replaceAll("#" + key + "#", "'" + String.valueOf(value) + "'");
            }
         }
         if (sql.indexOf('#') != -1) {
            Log.e(TAG, "undefined parameter in sql: " + sql);
            return null;
         }
         Cursor cursor = dbObj.rawQuery(sql, null);
         List<Map<String, Object>> mapList = new ArrayList<Map<String, Object>>();
         if (cursor == null) { return null; }
         String[] columnNames = cursor.getColumnNames();
         while (cursor.moveToNext()) {
            Map<String, Object> map = new HashMap<String, Object>();
            int i = 0;
            for (String columnName : columnNames) {
               map.put(columnName, cursor.getString(i));
               i++;
            }
            mapList.add(map);
         }
         if (mapList.size() <= 0) { return null; }
         cursor.close();
         return mapList.get(0);
      } finally {
         dbObj.close();
      }
   }

   /**
    * 指定したSQLIDにparameterをmappingして、クエリする。結果mapをリストで返却。
    * 
    * <p>
    * mappingの時、parameterが足りない場合はnullを返す。
    * </p>
    * 
    * @param sqlId
    *           SQLID
    * @param bindParams
    *           sql parameter
    * 
    * @return List<Map<String, Object>> result
    */
   public List<Map<String, Object>> executeForMapList(int sqlId, Map<String, ? extends Object> bindParams) {
      getDbObject();
      try {
         String sql = context.getResources().getString(sqlId);
         if (bindParams != null) {
            Iterator<String> mapIterator = bindParams.keySet().iterator();
            while (mapIterator.hasNext()) {
               String key = mapIterator.next();
               Object value = bindParams.get(key);
               sql = sql.replaceAll("#" + key + "#", "'" + String.valueOf(value) + "'");
            }
         }
         if (sql.indexOf('#') != -1) {
            Log.e(TAG, "undefined parameter in sql: " + sql);
            return null;
         }
         Cursor cursor = dbObj.rawQuery(sql, null);
         List<Map<String, Object>> mapList = new ArrayList<Map<String, Object>>();
         if (cursor == null) { return null; }
         String[] columnNames = cursor.getColumnNames();
         while (cursor.moveToNext()) {
            Map<String, Object> map = new HashMap<String, Object>();
            int i = 0;
            for (String columnName : columnNames) {
               map.put(columnName, cursor.getString(i));
               i++;
            }
            mapList.add(map);
         }
         cursor.close();
         return mapList;
      } finally {
         dbObj.close();
      }
   }

   /**
    * 指定したSQLIDにparameterをmappingして、クエリする。結果beanで返却。
    * 
    * <p>
    * mappingの時、parameterが足りない場合はnullを返す。 また、結果がない場合nullを返す。
    * </p>
    * 
    * @param sqlId
    *           SQLID
    * @param bindParams
    *           sql parameter
    * @param bean
    *           bean class of result
    * 
    * @return List<Map<String, Object>> result
    */
   @SuppressWarnings({ "unchecked", "rawtypes" })
   public <T> T executeForBean(int sqlId, Map<String, ? extends Object> bindParams, Class bean) {
      getDbObject();
      try {
         String sql = context.getResources().getString(sqlId);
         if (bindParams != null) {
            Iterator<String> mapIterator = bindParams.keySet().iterator();
            while (mapIterator.hasNext()) {
               String key = mapIterator.next();
               Object value = bindParams.get(key);
               sql = sql.replaceAll("#" + key + "#", "'" + String.valueOf(value) + "'");
            }
         }
         if (sql.indexOf('#') != -1) {
            Log.e(TAG, "undefined parameter in sql: " + sql);
            return null;
         }
         Cursor cursor = dbObj.rawQuery(sql, null);
         List<T> objectList = new ArrayList<T>();
         if (cursor == null) { return null; }
         String[] columnNames = cursor.getColumnNames();
         List<String> dataNames = new ArrayList<String>();
         for (String columnName : columnNames) {
            dataNames.add(chgDataName(columnName));
         }
         T beanObj = null;
         // get bean class package
         Package beanPackage = bean.getPackage();
         while (cursor.moveToNext()) {
            Map<String, Object> map = new HashMap<String, Object>();
            int i = 0;
            for (String dataName : dataNames) {
               map.put(dataName, cursor.getString(i));
               i++;
            }
            JSONObject json = new JSONObject(map);
            try {
               beanObj = (T) parse(json.toString(), bean, beanPackage.getName());
            } catch (Exception e) {
               Log.d(TAG, e.toString());
               return null;
            }
            objectList.add(beanObj);
         }
         if (objectList.size() <= 0) { return null; }
         cursor.close();
         return objectList.get(0);
      } finally {
         dbObj.close();
      }
   }

   /**
    * 指定したSQLIDにparameterをmappingして、クエリする。結果beanをリストで返却。
    * 
    * <p>
    * mappingの時、parameterが足りない場合はnullを返す。
    * </p>
    * 
    * @param sqlId
    *           SQLID
    * @param bindParams
    *           sql parameter
    * @param bean
    *           bean class of result
    * 
    * @return List<Map<String, Object>> result
    */
   @SuppressWarnings({ "unchecked", "rawtypes" })
   public <T> List<T> executeForBeanList(int sqlId, Map<String, ? extends Object> bindParams, Class bean) {
      getDbObject();
      try {
         String sql = context.getResources().getString(sqlId);
         if (bindParams != null) {
            Iterator<String> mapIterator = bindParams.keySet().iterator();
            while (mapIterator.hasNext()) {
               String key = mapIterator.next();
               Object value = bindParams.get(key);
               sql = sql.replaceAll("#" + key + "#", "'" + String.valueOf(value) + "'");
            }
         }
         if (sql.indexOf('#') != -1) {
            Log.e(TAG, "undefined parameter in sql: " + sql);
            return null;
         }
         Cursor cursor = dbObj.rawQuery(sql, null);
         List<T> objectList = new ArrayList<T>();
         if (cursor == null) { return null; }
         String[] columnNames = cursor.getColumnNames();
         List<String> dataNames = new ArrayList<String>();
         for (String columnName : columnNames) {
            dataNames.add(chgDataName(columnName));
         }
         T beanObj = null;
         // get bean class package
         Package beanPackage = bean.getPackage();
         while (cursor.moveToNext()) {
            Map<String, Object> map = new HashMap<String, Object>();
            int i = 0;
            for (String dataName : dataNames) {
               map.put(dataName, cursor.getString(i));
               i++;
            }
            JSONObject json = new JSONObject(map);
            try {
               beanObj = (T) parse(json.toString(), bean, beanPackage.getName());
            } catch (Exception e) {
               Log.d(TAG, e.toString());
               return null;
            }
            objectList.add(beanObj);
         }
         cursor.close();
         return objectList;
      } finally {
         dbObj.close();
      }
   }

   /**
    * 指定したSQLIDにparameterをmappingして、実行する。
    * 
    * <p>
    * mappingの時、parameterが足りない場合は0を返す。
    * </p>
    * 
    * @param sqlId
    *           SQLiteDatabase object
    * @param bindParams
    *           old version value
    * 
    * @return int 実行によって影響をもらった行数
    */
   public int execute(int sqlId, Map<String, ? extends Object> bindParams) {
      getDbObject();
      try {
         int row = 0;
         String sql = context.getResources().getString(sqlId);
         if (bindParams != null) {
            Iterator<String> mapIterator = bindParams.keySet().iterator();
            while (mapIterator.hasNext()) {
               String key = mapIterator.next();
               Object value = bindParams.get(key);
               sql = sql.replaceAll("#" + key + "#", "'" + String.valueOf(value) + "'");
            }
         }
         if (sql.indexOf('#') != -1) {
            Log.e(TAG, "undefined parameter in sql: " + sql);
            return row;
         }
         try {
            dbObj.execSQL(sql);
            row += 1;
         } catch (SQLException e) {
            return row;
         }
         return row;
      } finally {
         dbObj.close();
      }
   }

   /**
    * SQLiteDatabase Objectを取得する。
    * 
    * @return SQLiteDatabase SQLiteDatabase Object
    */
   private SQLiteDatabase getDbObject() {
      if (dbObj == null || !dbObj.isOpen()) {
         dbObj = getWritableDatabase();
      }
      return dbObj;
   }

   /**
    * JsonStringからBeanに変換する。
    * 
    * @param jsonStr
    *           JSON String
    * @param beanClass
    *           Bean class
    * @param basePackage
    *           Base package name which includes all Bean classes
    * @return Object Bean
    * @throws Exception
    */
   @SuppressWarnings({ "rawtypes", "unchecked" })
   public Object parse(String jsonStr, Class beanClass, String basePackage) throws Exception {
      Object obj = null;
      JSONObject jsonObj = new JSONObject(jsonStr);
      // Check bean object
      if (beanClass == null) {
         Log.d(TAG, "Bean class is null");
         return null;
      }
      // Read Class member fields
      Field[] props = beanClass.getDeclaredFields();
      if (props == null || props.length == 0) {
         Log.d(TAG, "Class" + beanClass.getName() + " has no fields");
         return null;
      }
      // Create instance of this Bean class
      obj = beanClass.newInstance();
      // Set value of each member variable of this object
      for (int i = 0; i < props.length; i++) {
         String fieldName = props[i].getName();
         fieldName = fieldName.replaceAll("_", "");

         // Skip public and static fields
         if (props[i].getModifiers() == (Modifier.PUBLIC | Modifier.STATIC)) {
            continue;
         }
         // Date Type of Field
         Class type = props[i].getType();
         String typeName = type.getName();
         // Check for Custom type
         if (typeName.equals("int") || typeName.equals("java.lang.Integer")) {
            Class[] parms = { type };
            try {
               Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
               m.setAccessible(true);
               // Set value
               m.invoke(obj, jsonObj.getInt(fieldName));
            } catch (Exception ex) {
               Log.d(TAG, ex.getMessage());
            }
         } else if (typeName.equals("long") || typeName.equals("java.lang.Long")) {
            Class[] parms = { type };
            try {
               Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
               m.setAccessible(true);
               // Set value
               m.invoke(obj, jsonObj.getLong(fieldName));
            } catch (Exception ex) {
               Log.d(TAG, ex.getMessage());
            }
         } else if (typeName.equals("boolean") || typeName.equals("java.lang.Boolean")) {
            Class[] parms = { type };
            try {
               Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
               m.setAccessible(true);
               // Set value
               m.invoke(obj, jsonObj.getBoolean(fieldName));
            } catch (Exception ex) {
               Log.d(TAG, ex.getMessage());
            }
         } else if (typeName.equals("java.lang.String")) {
            Class[] parms = { type };
            try {
               Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
               m.setAccessible(true);
               // Set value
               m.invoke(obj, jsonObj.getString(fieldName));
            } catch (Exception ex) {
               Log.d(TAG, ex.getMessage());
            }
         } else if (typeName.equals("double") || typeName.equals("java.lang.Double")) {
            Class[] parms = { type };
            try {
               Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
               m.setAccessible(true);
               // Set value
               m.invoke(obj, jsonObj.getDouble(fieldName));
            } catch (Exception ex) {
               Log.d(TAG, ex.getMessage());
            }
         } else if (type.getName().equals(List.class.getName()) || type.getName().equals(ArrayList.class.getName())) {
            // Find out the Generic
            String generic = props[i].getGenericType().toString();
            if (generic.indexOf("<") != -1) {
               String genericType = generic.substring(generic.lastIndexOf("<") + 1, generic.lastIndexOf(">"));
               if (genericType != null) {
                  JSONArray array = null;
                  try {
                     array = jsonObj.getJSONArray(fieldName);
                  } catch (Exception ex) {
                     Log.d(TAG, ex.getMessage());
                     array = null;
                  }
                  if (array == null) {
                     continue;
                  }
                  ArrayList arrayList = new ArrayList();
                  for (int j = 0; j < array.length(); j++) {
                     arrayList.add(parse(array.getJSONObject(j).toString(), Class.forName(genericType), basePackage));
                  }
                  // Set value
                  Class[] parms = { type };
                  try {
                     Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
                     m.setAccessible(true);
                     m.invoke(obj, arrayList);
                  } catch (Exception ex) {
                     Log.d(TAG, ex.getMessage());
                  }
               }
            } else {
               // No generic defined
               generic = null;
            }
         } else if (typeName.startsWith(basePackage)) {
            Class[] parms = { type };
            try {
               Method m = beanClass.getDeclaredMethod(getBeanMethodName(fieldName, 1), parms);
               m.setAccessible(true);
               // Set value
               JSONObject customObj = jsonObj.getJSONObject(fieldName);
               if (customObj != null) {
                  m.invoke(obj, parse(customObj.toString(), type, basePackage));
               }
            } catch (JSONException ex) {
               Log.d(TAG, ex.getMessage());
            }
         } else {
            // Skip
            Log.d(TAG, "Field " + fieldName + "#" + typeName + " is skip");
         }
      }
      return obj;
   }

   /**
    * BeanClass fields名からmethod名を取得する。
    * 
    * @param fieldName
    * @param type
    * @return String MethodName
    */
   private String getBeanMethodName(String fieldName, int type) {
      if (fieldName == null || fieldName == "") { return ""; }
      String methodName = "";
      if (type == 0) {
         methodName = "get";
      } else {
         methodName = "set";
      }
      methodName += fieldName.substring(0, 1).toUpperCase();
      if (fieldName.length() == 1) { return methodName; }
      methodName += fieldName.substring(1);
      //Log.d(TAG, "fieldName: " + fieldName + " beanMethod: " + methodName);
      return methodName;
   }

   /**
    * Databaseカラム名をjava bean名に変換する。
    * 
    * @param targetStr
    *           databaseカラム名
    * @return String bean data名
    */
   private String chgDataName(String targetStr) {
      Pattern p = Pattern.compile("_([a-z])");
      Matcher m = p.matcher(targetStr);

      StringBuffer sb = new StringBuffer(targetStr.length());
      while (m.find()) {
         m.appendReplacement(sb, m.group(1).toUpperCase());
      }
      m.appendTail(sb);
      return sb.toString();
   }
}