# FishingStories 0.9.0 BETA
Fishing Diary and Predictor

REQUIREMENTS:
Proper installation and use of FishingStories requires Python3 and Docker to be installed on the computer from which it is run.  The application has been tested with Python 3.9.7 and Python 3.10.5

Python: https://www.python.org/downloads/

Docker: (on Windows) https://hub.docker.com/editions/community/docker-ce-desktop-windows/
        or (on macOS) https://docs.docker.com/docker-for-mac/install/
        

PARTIALLY AUTOMATED INSTALLATION:
1. Download fishingstories.zip
2. Unzip fishingstories.zip
3. Start Docker
4. Open a terminal/console
5. Change directory to the root directory of fishingstories.  This will be the outer most directory named "fishingstories_1_0_0" within the directory where the fishingstories.zip was unzipped
6. In the terminal, type fishingstories_install_win.bat (on windos) or fishingstories_install.sh (on macOS), then press enter (return)
7. After this step, if no error messages are received, skip to ACCESSING THE APP below.

MANUAL INSTALLATION:
1. Download fishingstories.zip
2. Unzip fishingstories.zip
3. Start Docker
4. Open a terminal/console
5. Change directory to the root directory of fishingstories.  This will be the outer most directory named "fishingstories_1_0_0" within the directory where the fishingstories.zip was unzipped
6. In the terminal, ensure docker is running with the command: docker compose ls
7. Run the command: docker compose up -d (note you must be in the proper directory described in step 5).
8. In the terminal/console, type the command: cat fishing_stories.sql | docker exec -i fishing_container psql, then press enter (note: in windows use type instead of cat in this command)


MANUALLY CREATING APP ENVIRONMENT:
To start the application,
1. Open a terminal or console window.
2. Change directories to the root directory of fishingstories.  This will be the outermost directory withing the directory, in which fishingstories.zip was unzipped
3. Create a virtual environment with the command python -m venv .venv (on windows) or python3 -m venv .venv (on macOS). Python3 must be installed on the computer.
4. Activate the virtual environment with the command: .venv/Scripts/activate (on windows) or source .venv/bin/activate (on macOS)
5. Install dependencies with the command: pip install -r requirements.txt
6. Start the application with the command: python run.py (on windows) or python3 run.py (on mac OS)


ACCESSING THE APP:
FishingStories may be accessed through web browser.  The URL is localhost:5000.  The application must be started to access the app.

There is a default administrator login:  Username: admin, Password: admin.  The password should be changed.

To access the Angler interface, Register to ceate an account.




DEVELOPMENT NOTES:

6/8/2022
Database implemented as sql script and generated by sqlalchemy.orm objects.  Plan will be to create an alembic version that 
creates the database, allowing later migrations and rollbacks

As a component of the application, scrapy is used to obtain current data, based on a location.  Implementation considerations
include loading the locations available on the scraped site or to do a k-nearest neighbors analysis on locations in the database
that are near an entered location by the user

Forms are created for adding bait, gear, and angler ranks.  A basic layout is implemented currently, but this can be improved
once functionality is implemented.  Password hashing is explored in a tester and will be utilized in for a complete version.

6/9/2022
Had to ditch scrapy for scraping from websites.  Too much overhead with threading.  Instead, using requests and scrapy.selector
for parsing the html.
Solved the problem of the two forms not posting properly from /fishing_spots.  Had to check that the data for the hidden field
in the view_form is not None.  Also, added the value=spot.name to the hidden file spot_name attribute in the template html.

The web scraping works well, pulling a lot of great data from two web sites.  Need to implement location changing for these.
Also want to implement the entry of coordinates (perhaps from a google map search on a place), from which near by locations
with tidal data can be determined.

6/11/2022
Fixed bugs with scraping data and transferring it to objects.  Changed the object model in retrieve_tide_current to do this.
Still need to get high, low tide info from retrieve_weather.  Still need to get time zone (ex. EDT) from
retrieve_tide_current.  spot-view.html template renders all of the available data now.  Need to start and finish other
interfaces to completely load interact with db across the model.  Want to implement hashed password authentication.  If time,
may check out OAuth.  To complete, pattern recognition of fishing data related to weather and tide_current data/location.
Would be nice to pretty this up with css and js scripts.

6/13/2022
Major changes to app structure.  Now uses alembic to migrate db, generating initial db from model.  Used duck typing with a
class that faked SQLAlchemy from Flask-SQLAlchemy.  Did this to remain independent from Flask-SQLAlchemy to be able to use
sqlalchemy directly.  Added the requirements.txt file.  Changed initial page to login page.  Added password hashing to UserAccount
class.  Still need to complete implementation of login.  Plan to break apart api more.  Need to test db relations.  I think I have
to add some relations to the models classes to allow for joins.

Login and password hashing is implemented.  Appropriate pages require login.  Still need to implement registration.  Added basic cs
to base.html.

Modified data model, changing relationship between user_accounts and anglers such that user_accounts does not require a foreign
key to an angler record.  This is to accommodate Administrator user_accounts, which may not actually be an angler.  Thus, the
foreign key, angler_id, is no longer NOT NULL (ie is now nullable=True).

6/14/2022
Login with hashing working.  User registration working, which required the addition of entry of priviledges, account_types, and ranks
to be completed.  Changed css slightly to make the login centered and put a light background on tables to overlay the bocy background.
Tables with class="data-display-table" will do this.  Database with foreign keys and relationships working for Priviledges, AccountType,
UserAccount, Angler, Rank.  Angler may still need some adjustment to relationships with further relations.

Design accommodates the addition of a new user on registration and separate addition of administrators.  The register endpoint will
create and angler record and associate this with the new user.  A separate management app can be built to register administrators.

6/15/2022
Major change.  Split up admin and frontend.  Changes layout to accommodate this, placing db, model, etc in src folder.  This change is
accompanied by the addition of werkzeug.middleware.dispatcher.DispatcherMiddleware to allow routing to the admin or frontend apps.
This will facilitate the differences in functionality of a regular user and admin.  The current implementation works for starting
both apps on a development werkzeug wsgi server.  Administrator endpoints will be prefixed with /admin.  Need to finalize this change
by being able to navigate back to frontend on logout of admin app.  Then need to build, build, build endpoints.  Plan had been to
ensure relationships in data model were all functioning correctly today.  The admin app will be used to do this, since the frontend
functionality will be largely a subset of the admin functionality.  The 6/14/2022 branch is the last containing a single app
implementation.  Once the version with middleware is completed, the 6/14/2022 branch could be fully implemented with the frontend.
Their functionality should be identical, except for the routing to admin in the middleware-containing version.

6/19/2022
Implementing endpoints.  Able to create ranks, privileges, edit anglers.  Adhering to RESTful API conventions.  In order to implement
the PATCH method to update the angler rank (and for further update functions), added jquery min 3.5.0, pulled in as script from online.
Also had to utilize ajax with redirection to send the put request to the server.  To view the angler, a FlaskForm subclass with all
read-only fields is implemented and rendered in a template.  This paradigm can be repeated for other data edit procedures.

Need to complete all endpoint, including the fishing spot data access from scraping.  Still want to do site categorization for sites
selected by a user, which are not directly at sites having current data.  The plan is to utilize the gps coordinates along with other
potential features of the intended fishing spot to categorize it as a favorable fishing spot.  Ultimately, data analysis can provide
prediction of fishing success at known spots and newly selected fishing spots by comparison to the known spots.
