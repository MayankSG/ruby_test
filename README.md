- Clone of the repository on your local machine

- Run `docker compose up --buid` 

- By default it will scrap data for google.com

- Change the url in docker compose file for the web page you want to scrap the data

   - invoked your program like this: `docker compose up` then in our current directory we will have a file containing the contents of url given in docker-compose.yml, you need to remove --metadata from the url given.

   - To record metadata about what was fetched you just need to add --metadata in the docker-compose file, your output will be saved in output.txt 

