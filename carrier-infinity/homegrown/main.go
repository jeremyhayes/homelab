package main

import (
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
)

func main() {
	// setup handler for inbooud requests
//	http.HandleFunc("/", handle)
//        log.Print("starting up on :8080")
//	log.Fatal(http.ListenAndServe(":8080", nil))

	handler := http.DefaultServeMux
	handler.HandleFunc("/", handle)

	server := &http.Server{
		Addr:		":8080",
		Handler:	handler,
	}

	log.Fatal(server.ListenAndServe())
}

func copy(body io.ReadCloser) (stream io.ReadCloser, text *string) {
	if body == nil {
		return body, nil
	}

	buffer, _ := ioutil.ReadAll(body)
	// close original body before replacing with copy
	body.Close()
	body = ioutil.NopCloser(bytes.NewBuffer(buffer))

	copy := new(bytes.Buffer)
	copy.Write(buffer)
	result := copy.String()
	return body, &result
}

func handle(res http.ResponseWriter, req *http.Request) {
	// log request
//        fmt.Println("logging the whole thing")
	fmt.Printf("the whole thing %+v\n", req)
	log.Printf("--> %v %v", req.Method, req.URL)
	for k, v := range req.Header {
		log.Printf("--> %v: %v", k, v)
	}
	reqBodyCopy, reqBodyString := copy(req.Body)
	req.Body = reqBodyCopy
	if reqBodyString != nil {
		log.Printf("--> \n%v", *reqBodyString)
	}

//	fmt.Println("here's the whole request url...")
//	fmt.Printf("request.URL: %+v\n", req.URL)
//	fmt.Printf("IsAbs: %v", req.URL.IsAbs())

	// build proxy request
	preq := http.Request{
		Method:        req.Method,
//		URL:           "http://www.api.ing.carrier.com" + req.URL,
		URL:           req.URL,
//                Host:          req.Host,
		Header:        req.Header,
		Body:          req.Body,
		ContentLength: req.ContentLength,
		Close:         req.Close,
	}

	preq.URL.Scheme = "http"
	preq.URL.Host = "www.api.ing.carrier.com"

	// forward to destination
	pres, err := http.DefaultTransport.RoundTrip(&preq)
//	defer pres.Body.Close()
        if (err != nil) {
		log.Print("something bit me!!");
		log.Print(err);
	}

	// log response
        log.Printf("<-- %v", pres.Status)
	resBodyCopy, resBodyString := copy(pres.Body)
	pres.Body = resBodyCopy

	// copy proxy response
	for k, v := range pres.Header {
		res.Header()[k] = v
		log.Printf("<-- %v: %v", k, v)
	}

	// have to do this after headers, but before body
	res.WriteHeader(pres.StatusCode)

	// temp because fake endpoint doesn't let me set headers
	if pres.ContentLength > 0 {
		io.CopyN(res, pres.Body, pres.ContentLength)
	} else if pres.Close {
		for {
			_, err := io.Copy(res, pres.Body)
			if err != nil {
				break
			}
		}
	}

	if resBodyString != nil {
		log.Printf("<-- \n%v", *resBodyString)
	}
}

