# Home Assistant Custom Add-on: Kresus

[Kresus](https://kresus.org/) is an open-source self-hostable Personal Finance Manager.
It automatically retrieves your daily bank transactions, lets you categorize them and manage your monthly budgets.

It relies on [woob](https://gitlab.com/woob/woob) to fetch data from your bank website.

## Installation

Kresus requires a PostgreSQL database to store data.
If you do not already have a PostgreSQL database installed, you may consider the [PostgreSQL addon](https://github.com/ezlo-picori/hassio-addons/tree/main/postgres).

The installation of Kresus add-on is quite straightforward and do not differ from the standard installation process for Home-Assistant add-ons:

1. Click the Home Assistant My button below to open the add-on on your Home
   Assistant instance.

   [![Open this add-on in your Home Assistant instance.][addon-badge]][addon]

1. Click the "Install" button to install the add-on.
1. Start the "Kresus" add-on.
1. Check the logs of the "Kresus" add-on to see if everything
   went well. A working installation should indicate `Server is ready, let's start the show!`
1. Click the "OPEN WEB UI" button to open Kresus UI.

## Configuration

The only configuration configurations required are the database connection options.
If you used the [PostgreSQL add-on](https://github.com/ezlo-picori/hassio-addons/tree/main/postgres) configured with following options:

```yaml
databases:
  - kresus_db
logins:
  - password: CHANGEME_kr3sus-p@ssword_CHANGEME
    username: kresus_user
rights:
  - database: kresus_db
    username: kresus_user
```

then you may configure kresus with these options:

```yaml
postgres_hostname: homeassistant.local
postgres_port: 5432
postgres_user: kresus_user
postgres_password: CHANGEME_kr3sus-p@ssword_CHANGEME
postgres_database: kresus_db
```

## Authors & contributors

The original setup of this repository is by [Ezlo Picori](https://github.com/ezlo-picori).
