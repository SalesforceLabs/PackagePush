/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
public Virtual class RestApiClient {

Public Enum HttpVerb {GET, POST, PATCH, PUT, HEAD}
Public Static Final String APIVERSION = 'v45.0/';
Public Static Final String BASESOBJECTPATH = '/services/data/' + APIVERSION;
Public Static Final String QUERYPATH = BASESOBJECTPATH + 'query/?q=';
Public Static Final String SOBJECTPATH = BASESOBJECTPATH + 'sobjects/';
Boolean debug = true;

public String nc;

public RestApiClient(){
    
}

public RestApiClient(String setnc) {
  nc = setnc;
}

/*
Public String doGet(String queryString) {
    return makeApiCall(HttpVerb.GET, '', queryString, '').getBody();
}
*/

Public String query(String queryString) {
    return makeApiCall(HttpVerb.GET, QUERYPATH, queryString, '').getBody();
}

Public String postreq(String path, String data) {
    return makeApiCall(HttpVerb.POST, path, '', data).getBody();
}
Public String patchreq(String path, String data) {
    return makeApiCall(HttpVerb.PATCH, path, '', data).getBody();
}
    
Public HTTPResponse makeApiCall(HttpVerb method, String path, String query, String body){

    log('makeApiCall called');

    String encodedQuery = EncodingUtil.urlEncode(query, 'UTF-8');
    if(method == HttpVerb.PATCH){
      method = HttpVerb.POST;
      encodedQuery += '?_HttpMethod=PATCH';
    }
    HttpRequest apiRequest = new HttpRequest();
    apiRequest.setMethod(String.valueOf(method));
    if(String.isNotBlank(body) && (method == HttpVerb.POST || method == HttpVerb.PUT || method == HttpVerb.PATCH)){
      
      apiRequest.setBody(body);
      apiRequest.setHeader('Content-Type', 'application/json');
    }
    String endpoint = 'callout:' + nc + path + encodedQuery;
    apiRequest.setEndpoint(endpoint);
    log('endpoint=' + endpoint);
    Http http = new Http();
    HttpResponse toReturn = http.send(apiRequest);

    //log it
    if(String.isNotBlank(body) && (method == HttpVerb.POST || method == HttpVerb.PUT || method == HttpVerb.PATCH)){
      System.debug('makeApiCall body=' + body);
    }
    System.debug('makeApiCall toReturn=' + toReturn);
    System.debug('makeApiCall return body=' + toReturn.getBody().unescapeJava());
    
    if(toReturn.getStatusCode() > 299){

      System.debug('makeApiCall return body=' + toReturn.getBody().unescapeJava());
      System.debug('makeApiCall return path=' + path);
      System.debug('makeApiCall return query=' + query);
      System.debug('makeApiCall return body=' + body);
      System.debug('makeApiCall return location=' + toReturn.getHeader('Location'));
      
      //log(toReturn.getBody().unescapeJava());
      //log(path);
      //log(query);
      //log(body);
    }
    return toReturn;
  }

  /**
   * Convience version of makeApiCall without body param.
   * Invokes omnibus version above, with blank body param
   */
  /*
  Public HTTPResponse makeApiCall(HttpVerb method, String path, String query){
    return makeApiCall(method, path, query, '');
  }
*/

  /**
   * Convience version of makeApiCall without body or query params.
   * Invokes omnibus version above, with blank body and query params
   */
/*
  Public HTTPResponse makeApiCall(HttpVerb method, String path){
    return makeApiCall(method, path, '', '');
  }
*/

 Public Void log(Object o){
    if(debug){
      System.debug('\n' + o + '\n');
    }
  }    
    
}