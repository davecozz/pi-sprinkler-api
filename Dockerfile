FROM ruby:alpine

RUN gem install sinatra

COPY ./*rb /src

# COPY ./entrypoint.sh /entrypoint.sh
#
# RUN chmod +x /entrypoint.sh

EXPOSE 4567

ENTRYPOINT ["ruby", "/src/sprinkler.rb"]
