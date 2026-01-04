import requests
from bs4 import BeautifulSoup
import pandas as pd
import time

headers = {
    'Accept-Language': 'en-US,en;q=0.5',
}

def get_movie_data(movie_div):
    try:
        # Movie name and URL
        a_tag = movie_div.find('a')
        movie_name = a_tag['title'] if a_tag else 'N/A'
        movie_url = "https://www.themoviedb.org" + a_tag['href'] if a_tag else 'N/A'

        # Release date (updated selector)
        release_tag = movie_div.find('span', class_='release_date')
        release_date = release_tag.text.strip() if release_tag else 'N/A'

        # User review
        review_tag = movie_div.find('div', class_="user_score_chart")
        review = review_tag['data-percent'] if review_tag else 'N/A'

        # Movie detail page (safe)
        duration = 'N/A'
        genres = 'N/A'
        director = 'N/A'

        if movie_url != 'N/A':
            movie_response = requests.get(movie_url, headers=headers)
            movie_response.raise_for_status()
            movie_soup = BeautifulSoup(movie_response.text, 'lxml')

            # Runtime
            runtime_tag = movie_soup.find('span', class_='runtime')
            duration = runtime_tag.text.strip() if runtime_tag else 'N/A'

            # Genres
            genre_tags = movie_soup.find_all('span', class_='genres')
            genres = ', '.join([g.text.strip() for g in genre_tags]) if genre_tags else 'N/A'

            # Director
            director_tag = movie_soup.find('li', class_='profile')
            director = director_tag.find('a').text.strip() if director_tag else 'N/A'

        return {
            'movie_name': movie_name,
            'release_date': release_date,
            'review': review,
            'duration': duration,
            'genres': genres,
            'director': director
        }

    except Exception as e:
        print(f"Error scraping {movie_name if 'movie_name' in locals() else ''}: {e}")
        return {
            'movie_name': movie_name if 'movie_name' in locals() else 'N/A',
            'release_date': release_date if 'release_date' in locals() else 'N/A',
            'review': review if 'review' in locals() else 'N/A',
            'duration': 'N/A',
            'genres': 'N/A',
            'director': 'N/A'
        }

def fetch_movies_from_page(page_number):
    url = f"https://www.themoviedb.org/movie?page={page_number}"
    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response
    except requests.exceptions.HTTPError as http_err:
        print(f"HTTP error occurred: {http_err}")
    except Exception as e:
        print(f"Error fetching page {page_number}: {e}")
    return None

def scrape_movies(max_movies=50):
    movies_data = []
    page_number = 1

    while len(movies_data) < max_movies:
        res = fetch_movies_from_page(page_number)
        if res is None:
            page_number += 1
            time.sleep(1)
            continue

        soup_data = BeautifulSoup(res.text, 'lxml')
        movie_divs = soup_data.find_all('div', class_="card style_1")

        for movie_div in movie_divs:
            if len(movies_data) >= max_movies:
                break
            movie_info = get_movie_data(movie_div)
            movies_data.append(movie_info)

        print(f"Page {page_number} scraped, total movies: {len(movies_data)}")
        page_number += 1
        time.sleep(1)  # polite scraping

    return movies_data

def save_to_csv(movies_data, filename='tmdb_movies.csv'):
    df = pd.DataFrame(movies_data)
    df.to_csv(filename, index=False)
    print(f"Data saved to {filename}")

# Run scraper
movies_data = scrape_movies(max_movies=50)  # test 50 movies first
save_to_csv(movies_data)
