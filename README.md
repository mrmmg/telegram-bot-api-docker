# Run Your Own Telegram Bot API Server

1. Obtain your **app\_id** and **app\_hash** from Telegram.
   [Read more in the Telegram documentation](https://core.telegram.org/api/obtaining_api_id).

2. Create a `.env` file based on `.env.example` and fill in the required values.

3. Set the desired service port in the `.env` file.

4. Build and start the container:

   ```bash
   docker compose up -d --build
   ```

## Stay Updated on Bot API Releases

Join [@BotNews](https://t.me/BotNews) on Telegram. Whenever a new Bot API version is released, it’s recommended to update your Docker image to stay current.
