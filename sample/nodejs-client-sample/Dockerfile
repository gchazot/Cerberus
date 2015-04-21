FROM dockerfile/nodejs

COPY . /srv/app

RUN npm install -g forever; cd /srv/app; npm install

EXPOSE 3000

#VOLUME ["/data"]
#CMD cd /data; npm install; forever /data/cerberus-nodejs.js

CMD ["forever", "/srv/app/cerberus-nodejs.js"]
