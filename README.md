# Cinema
## Requirements
- Swift 4.2
- Vapor 3.0.0
- Docker 18.09
- *Xcode 10 optional*

## Build instructions 
1. Clone this repo `git clone git@github.com:emarashliev/Cinema.git`
2. Open `Cinema/server/` folder 
3. In your terminal, Run `docker-compose up -d`
4. Run the project
  * for bash or zsh users, Run `export API_KEY=test; vapor run` (your `apiKey` is `test` now)
  * or you can open the project in Xcode with `vapor xcode -y`.
  Then add the `API_KEY` as environment variable, like this👇
  ![alt text](https://github.com/emarashliev/Cinema/blob/master/setapiKey.png?raw=true "")

