year = int(input("What's your year of birth?\n"))

if year>1927 and year<1946:
    print("You are Silent Generation")
elif year>1945 and year<1965:
    print("You are Baby Boom Gen.")
elif year>1964 and year<1981:
    print("You are a Gen X")
elif year>1980 and year<1997:
    print("You are a millenial or Gen Y.")
elif year>1996 and year<2011:
    print("You are Gen Z.")
elif year>2009 and year<2025:
    print("You are Gen Alpha.")