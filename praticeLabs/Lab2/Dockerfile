FROM nginx:latest
# Create a directory for your HTML page
RUN mkdir -p /usr/share/nginx/html
COPY ./html/index.html /usr/share/nginx/html/index.html
# Define a volume for the web content
VOLUME /usr/share/nginx/html
# Nginx runs on port 80
EXPOSE 80
