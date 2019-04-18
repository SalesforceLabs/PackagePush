/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */
 
@IsTest
global class CalloutMock implements HttpCalloutMock {
  global class CalloutMockException extends Exception {}

  public  Map<Integer, CalloutMock> requests = new Map<Integer, CalloutMock>();
  public  Boolean                   multiRequest = false;
  private Integer                   mockIndex = 0;
  private Integer                   statusCode;
  private String                    status;
  private String                    bodyAsString;
  private Blob                      bodyAsBlob;
  private Map<String, String>       responseHeaders = new Map<String, String>();

  global HttpResponse respond(HttpRequest req){
    if(multiRequest){
      HttpCalloutMock mock = requests.remove(mockIndex);
      mockIndex += 1;
      if (mock != null) {
        return mock.respond(req);
      } else {
        throw new CalloutMockException('Mock not found for ' + req.getEndpoint() + ', and HTTP callout not supported for test methods');
      }
    } else {
      HttpResponse response = new HttpResponse();
      for(String key: responseHeaders.keySet()){
        response.setHeader(key, responseHeaders.get(key));
      }
      if(bodyAsString != null){
        response.setBody(bodyAsString);
      } else {
        response.setBodyAsBlob(bodyAsBlob);
      }
      response.setStatus(status);
      response.setStatusCode(statusCode);
      return response;
    }
  }

//Helper constructors.

  global CalloutMock(Integer statusCode, String status, String bodyAsString, Blob bodyAsBlob){
    this.statusCode = statusCode;
    this.status = status;
    this.bodyAsString = bodyAsString;
    this.bodyAsBlob = bodyAsBlob;
  }

  global CalloutMock(Map<Integer, CalloutMock> requests){
    this.multiRequest = true;
    this.requests = requests;
  }

  public static CalloutMock simpleSuccess(String body){
    return new CalloutMock(200, 'Ok', body, null);
  }

  public static CalloutMock simpleFailure(){
    return new CalloutMock(500, 'Internal Server Error', null, null);
  }

  public static CalloutMock notFoundFailure(){
    return new CalloutMock(404, 'Not Found', null, null);
  }

  public static CalloutMock created(String body){
    return new CalloutMock(201, 'Created', body, null);
  }

}