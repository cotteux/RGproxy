#!/usr/bin/env python3
#^^^^ <--> Nomadnet specific to prevent page caching, may change if you like.

import urllib.parse
import ignition
import textwrap
import time
import yaml
from os import environ
import os
page = []
redirect = ""
backlink = ""
backurl = ""
#with open("settings.yaml", "r") as file:
#    settings = yaml.safe_load(file)
#MYNODE = settings.get("MYNODE")        #config who's to listen
#USERS = settings.get("USERS")          # List of users

def onReceive(message):

    global redirect
    emptyline = ""
    iline = ""
    redirect = ""
    try:
            #message_parts = message.split(" ")
            reloadline = ""
            if message[:9] == "gemini://" :
                url = message[9:]
            elif message[:9] == "gopher://" :
                url = message[9:]
                line = "`F091`[Click here to go back to gopher`:/page/gopher.mu`resultat="+url+"]`f``"
                print (line)
                url =""
            else :
                url = message
            url = url.replace("@@","=")
            url = url.replace("##","?")
            url = url.replace("%%","&")

            master_path = ""
            master_spath = ""
            response = ignition.request("gemini://"+url)
            parsed =  urllib.parse.urlparse("gemini://"+url)

            master_scheme = parsed.scheme
            master_netloc = parsed.netloc
            master_spath1 = parsed.path
            master_spath = master_spath1.split("/" or "\n")
            
            for  spath in master_spath :
                if ".gmi" not in spath and spath != "" and ".gemini" not in spath and "index" not in spath:
                    master_path = master_path +"/" + spath 

            master_query = parsed.query
            home = master_netloc

            if response.is_a(ignition.SuccessResponse) and not ".txt" in url and not ".png" in url:
                print( "`B595 `!`["+master_netloc+"`:/page/rgproxy.mu`resultat="+master_netloc+"]`b`` "+url[:100])
                
                
                text = (response.data())
                text = text.replace("\t"," ")
                text = text.replace("\r","")
                tosend = text.split("\n")
                print ("---")
                for index, line in enumerate(tosend):

                    #line = line.replace("`","'")
                    if line[:3] == "```" :
                         line = "`="
                        
                    elif line[:3] == "###" :
                         line = ">>>"+line[3:]
                    elif line[:2] == "##" :
                        line = ">>"+line[2:]
                    elif line[:1] == "#" :
                        line = ">"+line[1:]
                    elif line[:2] == "=>":
                        line = line.replace("`","'")

                        line = line[2:].lstrip(" ")

                        line_part = line.split(" ",maxsplit=1)
                        requested_url = line_part[0]

                        #print (requested_url)

                        parsed =  urllib.parse.urlparse(requested_url)
                        #print ("==="+showlink)
                        request_scheme = parsed.scheme
                        request_netloc = parsed.netloc
                        request_path = parsed.path
                        request_query = parsed.query

                        if request_scheme =="gemini" or request_scheme =="gopher" or request_scheme =="" :
                            #print (parsed)
                            if len(line_part) ==1 :
                                showlink = line_part[0]
                            else :
                                showlink = line_part[1]
                            showlink = showlink.replace("[","{")
                            showlink = showlink.replace("]","}")
                            #print (showlink)

                            if request_path[:2] == "//" :
                                request_netloc = request_path[1:]
                                request_path = "" 
                            if ".gmi" in request_netloc or ".py" in request_netloc or ".txt" in request_netloc or ".md" in request_netloc:
                                if ".gmi" in request_path :
                                    request_netloc = master_netloc
                                else :
                                    request_path = "/"+request_netloc.lstrip("/")
                                    request_netloc = ""
                            elif ".gmi" in request_path :
                                findit = request_path.find(".gmi")+4
                                if findit < len(request_path) :
                                   #print (len(request_path)-findit)
                                   request_path = request_path[:-(len(request_path)-findit)]
                            if request_path[:2] ==".." :
                                request_path = request_path[2:]
                                request_netloc = ".."
                            if request_path[:1] =="." :
                                request_path = request_path[1:]
                                request_netloc = "."
                            if request_path[:1] !="/" :
                               symbol ="/"
                            else :
                               symbol = ""
                               if request_netloc =="":
                                   request_netloc=".."
                            if request_query !="" :
                               symbol2 ="?"
                            else :
                               symbol2 = ""
                            request_query = request_query.replace("=","@@")
                            request_query = request_query.replace("?","##")
                            request_query = request_query.replace("&","%%")
                            if request_netloc =="..":
                                line = "`F089`["+showlink+"`:/page/rgproxy.mu`resultat="+home.rstrip("/")+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                                #print(home.rstrip("/")+symbol+request_path+symbol2+request_query)
                            elif request_netloc =="." or (symbol =="/" and request_netloc==""):
                                line = "`F031`["+showlink+"`:/page/rgproxy.mu`resultat="+home.rstrip("/")+master_path+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                            elif request_netloc ==""  :
                                line = "`F039`[`"+showlink+"`:/page/rgproxy.mu`resultat="+home.rstrip("/")+master_path+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                            elif request_scheme =="gopher" :
                                line = "`F091`["+request_scheme+"://"+request_netloc+symbol+request_path+symbol2+request_query+"`:/page/gopher.mu`resultat="+request_netloc+symbol+request_path+symbol2+request_query+"|backurl=gemini://"+url+"]`f``"
                            else :
                                line = "`F099`["+showlink+"`:/page/rgproxy.mu`resultat="+request_netloc+symbol+request_path+symbol2+request_query+"|backurl="+url+"]`f``"
                        elif request_scheme =="http" or request_scheme =="https" or request_scheme =="spartan":
                            line = "`F669"+request_scheme+"://"+request_netloc+request_path+"`f"
                        else :
                            line = "`F669 Unusable link `f "

                    else :
                        line = line.replace("`","'")
                    print (line)

            elif response.is_a(ignition.SuccessResponse) and ".txt" in url:
                print ("`B195 Text `!`["+master_netloc+"`:/page/rgproxy.mu`resultat="+master_netloc+"]`b`` "+url)
                print ("---")
                text = (response.data())
                text = text.replace("\t","    ")
                text = text.replace("\r","")
                print (text)
                

            elif response.is_a(ignition.InputResponse):
                print ("Needs additional input: ")
                print ()
                print (f'{response.data()} ')
                print('`B444`<30|user_input`>`b  `!`B605`[Submit`:/page/rgproxy.mu`resultat='+url+'|user_input]`b')

            elif response.is_a(ignition.RedirectResponse):
                print(f"Received response, redirect to: {response.data()}")
                if response.data()[:9] == "gemini://":
                    redirect = response.data()

                else :
                    hurl = url.split("/")
                    home = hurl[0]
                    redirect = home+response.data()
                
            elif response.is_a(ignition.TempFailureResponse):
                print(f"Error from server: {response.data()}")

            elif response.is_a(ignition.PermFailureResponse):
                print(f"Error from server: {response.data()}")

            elif response.is_a(ignition.ClientCertRequiredResponse):
                print(f"Client certificate required. {response.data()}")

            elif response.is_a(ignition.ErrorResponse):
                print(f"There was an error on the request: {response.data()}")
            else :
                print (" not a compatible content on "+url)
    except KeyError as e:
        print(f"Error processing packet: {e}")

if environ.get("var_backurl") != None :
    backurl =  str(environ.get("var_backurl"))

print ("> Gemini Proxy          `F919 Beta Version, under construction no certificate and somes bugs`f")
print ("")
print ('Input gemini link or search term `B500gemini://`B444`<30|user_input`>`b  `!`B500`[Go to link`:/page/rgproxy.mu`user_input]`b or `!`B505`[Search`:/page/rgproxy.mu`resultat=kennedy.gemi.dev/search|user_input]`b')
print ("")
print ("`B559`!`[Main menu`:/page/index.mu]`b `B329`!`[Proxy Menu`:/page/rgproxy.mu`resultat=]`b  `B128`!`[Search Engine`:/page/rgproxy.mu`resultat=kennedy.gemi.dev]`b  `B659`!`[Back`:/page/rgproxy.mu`resultat="+backurl+"]`b")
print ("")

if environ.get("field_user_input") != None and environ.get("var_resultat") != None:
        os.environ['var_resultat'] =  environ.get("var_resultat")+"?"+environ.get("field_user_input")


if environ.get("field_user_input") != None and environ.get("var_resultat") == None:
        os.environ['var_resultat'] =  environ.get("field_user_input")

if   environ.get("var_resultat") == None or environ.get("var_resultat") == "":
      
        print ('>> Bookmarks')
        print ("")
        print  ('`!`[Gemi.dev`:/page/rgproxy.mu`resultat=gemi.dev]')
        print ("")
        print  ('`!`[Techrights`:/page/rgproxy.mu`resultat=gemini.techrights.org]')
        print ("")
        print  ('`!`[GeminiSpace`:/page/rgproxy.mu`resultat=bbs.geminispace.org]')
        print ("")
        print  ('`!`[Noulin Bookmarks`:/page/rgproxy.mu`resultat=gmi.noulin.net]')
        print ("")
        print  ('`!`[Auragem`:/page/rgproxy.mu`resultat=auragem.letz.dev]')
        print ("")
        print  ('`!`[Yesterweb`:/page/rgproxy.mu`resultat=cities.yesterweb.org]')
        print ("")
        print  ('`!`[Hyperreal`:/page/rgproxy.mu`resultat=hyperreal.coffee]')
        print ("")
        print  ('`!`[That it be`:/page/rgproxy.mu`resultat=thatit.be]')
        print ("")
        print  ('`!`[Kelbots Gem-port`:/page/rgproxy.mu`resultat=gemini.cyberbot.space]')
        print ("")
        print  ('`!`[test gopher link`:/page/rgproxy.mu`resultat=gopher.zcrayfish.soy]')
        print ("")
        print (">> Games")
        print ("")
        print  ('`!`[Flower Flood`:/page/rgproxy.mu`resultat=gem.bahai.fyi/flower/]')
        print ("")
        print  ('`!`[Underground Kingdom`:/page/rgproxy.mu`resultat=typed-hole.org/cyoa/underground]')
        print ("")
        print  ('`!`[Secret of Pyramids`:/page/rgproxy.mu`resultat=typed-hole.org/cyoa2/pyramid.gemini]')
        print ("")
        print ('`!`[Twisty Puzzles (5 interactive puzzles)`:/page/rgproxy.mu`resultat=jsreed5.org/twisty/index.gmi]')
        print ("")


else :
        #print (environ.get("var_resultat"))
        onReceive(environ.get("var_resultat"))
        #print (redirect)
        if redirect !="" :
            onReceive(redirect)
            print ("redirect to "+redirect)

        print ("you're on "+environ.get("var_resultat"))
