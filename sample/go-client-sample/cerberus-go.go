package main

import (
        "html/template"
        "io/ioutil"
        "net/http"
        "net/url"
        "crypto/tls"
        "encoding/json"
)

var clientID string = "to be filled"
var clientSecret string  = "to be filled"
var oauth_server string = "to be filled"
var userInfoApi string = oauth_server + "/api/user.info.json?access_token="

func oauthHandler(w http.ResponseWriter, r *http.Request) {
    // Request authorisation token
    var url string = site + "/oauth/authorize?client_id=" + clientID + "&redirect_uri=http://" + r.Host  + "/cerberus-go/callback&response_type=code"
    http.Redirect(w, r, url, http.StatusFound)
}

func callbackHandler(w http.ResponseWriter, r *http.Request) {
    // Request access token
    u, _ := url.Parse(r.URL.String())
    queryParams := u.Query()
    var url string = site + "/oauth/token?client_id=" + clientID + "&client_secret=" + clientSecret + "&code=" + queryParams.Get("code") + "&grant_type=authorization_code" + "&redirect_uri=http://" + r.Host  + "/cerberus-go/callback"

    resp, err := http.Get(url)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()

    bb, _ := ioutil.ReadAll(resp.Body)    
    var dat map[string]interface{}
    if err := json.Unmarshal(bb, &dat); err != nil {
        panic(err)
    }
    var access_token = dat["access_token"].(string)

	// Test access token
    var api_request = userInfoApi + access_token
    resp_test, err := http.Get(api_request)
    defer resp_test.Body.Close()
    resp_test.Write(w)
}

func renderTemplate(w http.ResponseWriter, tmpl string) {
    t, _ := template.ParseFiles(tmpl + ".html")
    t.Execute(w,nil)
}

func viewHandler(w http.ResponseWriter, r *http.Request) {
    renderTemplate(w, "view")
}

func main() {
   cfg := &tls.Config{
      InsecureSkipVerify: true,
   }

   http.DefaultClient.Transport = &http.Transport{
      TLSClientConfig: cfg,
   }

    http.HandleFunc("/cerberus-go", viewHandler)
    http.HandleFunc("/cerberus-go/oauth", oauthHandler)
    http.HandleFunc("/cerberus-go/callback", callbackHandler)
    http.ListenAndServe(":8888", nil)
}

