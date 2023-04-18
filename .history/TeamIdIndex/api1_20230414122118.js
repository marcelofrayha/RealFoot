const teamsTable = {
    england: {
        57: 1, // Arsenal
        65: 2, // Manchester City
        66: 3, // Manchester United
        73: 4, // Tottenham Hotspur
        67: 5, // Newcastle United
        64: 6, // Liverpool
        397: 7, // Brighton & Hove Albion
        402: 8, // Brentford
        63: 9, // Fulham
        61: 10, // Chelsea
        58: 11, // Aston Villa
        354: 12, // Crystal Palace
        76: 13, // Wolverhampton Wanderers
        341: 14, // Leeds United
        62: 15, // Everton
        351: 16, // Nottingham Forest
        338: 17, // Leicester City
        563: 18, // West Ham United
        1044: 19, // AFC Bournemouth
        340: 20 // Southampton
    },
    brazil: {
        1838: 1,  // America MG
        1768: 2,  // Athletico Paranaense
        1766: 3,  // Atletico MG
        1777: 4,  // Bahia
        1770: 5,  // Botafogo FR
        1779: 6,  // Corinthians
        4241: 7,  // Coritiba
        1771: 8,  // Cruzeiro
        4289: 9,  // Cuiaba
        1783: 10,  // Flamengo
        1765: 11,  // Fluminense
        3984: 12,  // Fortaleza
        4250: 13,  // Goias
        1767: 14,  // Gremio
        6684: 15,  // Internacional
        1769: 16,  // Palmeiras
        4286: 17,  // Bragantino
        6685: 18,  // Santos FC
        1776: 19,  // Sao Paulo
        1780: 20  // Vasco da Gama
         
    },
    spain: {
        81: 1, // Barcelona
        86: 2, // Real Madrid
        78: 3, // Atletico Madrid
        92: 4, // Real Sociedad
        90: 5, // Real Betis
        94: 6, // Villarreal
        77: 7, // Athletic Bilbao
        87: 8, // Rayo Vallecano
        79: 9, // Osasuna
        558: 10, // Celta Vigo
        89: 11, // Mallorca
        298: 12, // Girona
        82: 13, // Getafe
        559: 14, // Sevilla
        264: 15, // Cadiz
        250: 16, // Real Valladolid
        80: 17, // Espanyol
        95: 18, // Valencia
        267: 19, // Almeria
        285: 20, // Elche  
    },
    italy: {
        113: 1, // Napoli
        110: 2, // Lazio
        108: 3, // Inter
        98: 4, // AC Milan
        100: 5, // Roma
        102: 6, // Atalanta
        109: 7, // Juventus
        115: 8, // Udinese
        99: 9, // Fiorentina
        103: 10, // Bologna
        586: 11, // Torino
        471: 12, // Sassuolo
        5911: 13, // Monza
        445: 14, // Empoli
        5890: 15, // Lecce
        455: 16, // Salernitana
        488: 17, // Spezia
        450: 18, // Verona
        584: 19, // Sampdoria
        457: 20, // Cremonese
    },
    germany: {
        4: 1,  // Borussia Dortmund
        5: 2,  // Bayern Munich
        28: 3,  // Union Berlin
        17: 4,  // Freiburg
        721: 5,  // RB Leipzig
        19: 6,  // Eintracht Frankfurt
        11: 7,  // Wolfsburg
        3: 8,  // Bayer Leverkusen
        15: 9,  // Mainz
        18: 10,  // Borussia Monchengladbach
        12: 11,  // Werder Bremen
        16: 12,  // Augsburg
        1: 13,  // FC Cologne
        36: 14,  // Bochum
        2: 15,  // Hoffenheim
        9: 16,  // Hertha Berlin
        6: 17,  // Schalke 04
        10: 18  // VfB Stuttgart
    },
    france: {   
        524: 1, // Paris Saint-Germain
        516: 2, // Marseille
        546: 3, // Lens
        548: 4, // Monaco
        529: 5, // Rennes
        521: 6, // Lille
        522: 7, // Nice
        525: 8, // Lorient
        547: 9, // Reims
        523: 10, // Lyon
        518: 11, // Montpellier
        511: 12, // Toulouse
        541: 13, // Clermont Foot
        543: 14, // Nantes
        576: 15, // Strasbourg
        512: 16, // Brest
        519: 17, // Auxerre
        531: 18, // Troyes
        510: 19, // AC Ajaccio
        532: 20 // Angers
    },
    // argentina: {
    //     4802: 1, // River Plate
    //     3507: 2, // San Lorenzo de Almagro
    //     5190: 3, // Defensa y Justicia
    //     4503: 4, // Racing Club
    //     5219: 5, // Lanus
    //     5202: 6, // Newell's Old Boys
    //     5197: 7, // Rosario Central
    //     3508: 8, // Talleres
    //     6879: 9, // Instituto Cordoba
    //     5221: 10, // Velez Sarsfield
    //     4300: 11, // CA Huracan
    //     5213: 12, // Godoy Cruz Antonio Tomba
    //     5229: 13, // Argentinos Juniors
    //     4572: 14, // Boca Juniors
    //     6846: 15, // Belgrano
    //     6851: 16, // Club Atletico Platense
    //     6839: 17, // Barracas Central
    //     5252: 18, // Banfield
    //     6872: 19, // Sarmiento
    //     4801: 20 // Independiente
    // },
    portugal: {
        1903: 1, // Sport Lisboa e Benfica
        503: 2, // FC Porto
        5613: 3, // Sporting Clube de Braga
        498: 4, // Sporting Clube de Portugal
        5543: 5, // Vitória SC
        6618: 6, // Casa Pia AC
        712: 7, // FC Arouca
        496: 8, // Rio Ave FC
        5531: 9, // FC Famalicão
        5589: 10, // FC Vizela
        1103: 11, // GD Chaves
        810: 12, // Boavista FC
        5533: 13, // Gil Vicente FC
        5601: 14, // Portimonense SC
        582: 15, // GD Estoril Praia
        507: 16, // FC Paços de Ferreira
        5575: 17, // CS Marítimo
        5530: 18 // CD Santa Clara
    }
}
/*
england
premier-league
spain
laliga-santander
italy
serie-a
germany
bundesliga
france
ligue-1
argentina
primera-division
brazil
serie-a
*/

module.exports = teamsTable;