package com.tobykurien.webapps.data;

@SuppressWarnings("all")
public class Webapp {
  private long _id;
  
  public long getId() {
    return this._id;
  }
  
  public void setId(final long id) {
    this._id = id;
  }
  
  private String _name;
  
  public String getName() {
    return this._name;
  }
  
  public void setName(final String name) {
    this._name = name;
  }
  
  private String _url;
  
  public String getUrl() {
    return this._url;
  }
  
  public void setUrl(final String url) {
    this._url = url;
  }
  
  private String _iconUrl;
  
  public String getIconUrl() {
    return this._iconUrl;
  }
  
  public void setIconUrl(final String iconUrl) {
    this._iconUrl = iconUrl;
  }
  
  public String toString() {
    String _name = this.getName();
    return _name;
  }
}
