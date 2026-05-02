
/* global Puvar, Karichal, Mangalore, New_Mangalore, Suratkal_pt, Mulki */

$(document).ready(function () {
    var hashtable = {};
    hashtable['Mangalore'] = ["12.85", "74.84"];
    hashtable['New_Mangalore'] = ["12.93", "74.84"];
    hashtable['Suratkal_pt'] = ["13", "74.79"];
    hashtable['Mulki'] = ["13", "74.79"];
    hashtable['Kapu'] = ["13.22", "74.74"];
    hashtable['Udyavara'] = ["13.3", "74.74"];
    hashtable['Malpe'] = ["13.34", "74.68"];
    hashtable['Hangarkatta'] = ["13.44", "74.71"];
    hashtable['Kota'] = ["13.51", "74.71"];
    hashtable['Coondapur'] = ["13.62", "74.67"];
    hashtable['Gangoli'] = ["13.66", "74.66"];
    hashtable['Navunda'] = ["13.75", "74.64"];
    hashtable['Baindur'] = ["13.87", "74.63"];
    hashtable['Bhatkal'] = ["13.97", "74.53"];
    hashtable['Shirali'] = ["14.04", "74.52"];
    hashtable['Mavalli'] = ["14.11", "74.49"];
    hashtable['Navayatkere'] = ["14.19", "74.47"];
    hashtable['Kasarkod'] = ["14.25", "74.44"];
    hashtable['Honavar'] = ["14.28", "74.44"];
    hashtable['Karki'] = ["14.32", "74.43"];
    hashtable['Dhareshvar'] = ["14.38", "74.41"];
    hashtable['Kumta Pt'] = ["14.38", "74.41"];
    //Goa Landing centers
    hashtable['Aguada'] = ["15.48865", "73.77317"];
    hashtable['Panaji_(Malim)'] = ["15.493702", "73.831535"];
    hashtable['Santerem_Pt_(Vasco)'] = ["15.349222", "73.763474"];
    hashtable['Majorde'] = ["15.311026", "73.911674"];
    hashtable['Fatarde'] = ["15.212647", "73.935753"];
    hashtable['Betul'] = ["15.133424", "73.945816"];
    hashtable['Cutbona'] = ["15.08442974", "73.91555786"];
    hashtable['Talpona'] = [, "14.980125", "74.04393"];
    hashtable['Kolamb'] = ["14.959863", "74.053627"];
    hashtable['Chapora'] = ["15.592642", "73.738457"];
    //West bengal landing centers
    hashtable['Digha'] = ["21.67746162", "87.6936264"];
    hashtable['Shankarpur'] = ["21.670315", "87.566833"];
    hashtable['Petuaghat_(Dariapur)'] = ["21.789017", "87.867126"];
    hashtable['Diamond_Harbour'] = ["22.1861248", "88.19710541"];
    hashtable['Kakdwip'] = ["21.88105011", "88.17041016"];
    hashtable['Namkhana'] = ["21.81414223", "21.81414223"];
    hashtable['Sagar'] = ["21.655376", "88.050766"];
    hashtable['Frasergunje'] = ["21.5795517", "88.25024414"];
    hashtable['Lothian_Island'] = ["21.607294", "88.317654"];
    //andaman landing centers
    hashtable['Landfall'] = ["13.628248", "93.051971"];
    hashtable['Diglipur'] = ["13.297643", "93.077126"];
    hashtable['Mayabunder'] = ["12.92499", "92.979378"];
    hashtable['Elphinstone_Hr'] = ["12.317615", "92.896362"];
    hashtable['Middle_Strait'] = ["12.078647", "92.792503"];
    hashtable['Port_Blair'] = ["11.701374", "92.75692"];
    hashtable['Mt_Haughton'] = ["11.645057", "92.749374"];
    hashtable['Rutland'] = ["11.343085", "92.612816"];
    hashtable['Cinque_Island'] = ["11.323936", "92.722061"];
    hashtable['Neil_Island'] = ["11.783174", "93.083595"];
    hashtable['Barren'] = ["12.278391", "93.847984"];
    hashtable['Narcondam'] = ["13.453506", "94.254799"];
    hashtable['Tambe-e-bul'] = ["10.81322098", "92.5582428"];
    hashtable['Kwate-tu-Kwage'] = ["10.593158", "92.563934"];
    hashtable['Benyaboi'] = ["10.511374", "92.503563"];
    hashtable['Tula'] = ["10.62718391", "92.42108917"];
    hashtable['Tochangeou'] = ["10.73930168", "92.38319397"];
    //lakshadweep
    hashtable['Valiyapani_reef'] = ["12.33034706", "71.91112518"];
    hashtable['Byramgore'] = ["11.858577", "	71.829102"];
    hashtable['Cheriyapani_reef'] = ["11.8337698", "71.81244659"];
    hashtable['Chetlat_I'] = ["11.695", "72.718193"];
    hashtable['Bitra_I'] = ["11.59671593", "72.17936707"];
    hashtable['Kiltani'] = ["11.495175", "73.000305"];
    hashtable['Perumalpar_reef'] = ["11.20444298", "72.103302"];
    hashtable['Kadmath_I'] = ["11.21983242", "72.77648163"];
    hashtable['Amini_I'] = ["11.111425", "72.721786"];
    hashtable['Tinnakara'] = ["10.941375", "72.318207"];
    hashtable['Bangaram_I'] = ["10.9355526", "72.29076385"];
    hashtable['Agatti_I'] = ["10.873185", "72.203926"];
    hashtable['Androth_I'] = ["10.811374", "73.701805"];
    hashtable['Kavaratti_I'] = ["10.560802", "72.647758"];
    hashtable['Valiykara'] = ["10.133468", "72.327553"];
    hashtable['Suheli'] = ["10.0413332", "72.28672791"];
    hashtable['Cheriyakara'] = ["10.037317", "72.282631"];
    hashtable['Kalpeni_I'] = ["10.081479", "73.648254"];
    hashtable['Minicoy'] = ["8.266122", "73.025459"];
    //odissa landing Centers
    hashtable['Ekasingi'] = ["19.158516", "84.80648"];
    hashtable['New_Golabandha'] = ["19.22471619", "84.87025452"];
    hashtable['Gopalpur'] = ["	19.253605", "84.908035"];
    hashtable['Sana_Aryapalli'] = ["19.31698799", "84.98417664"];
    hashtable['Ganjam'] = ["19.38888168", "85.05004883"];
    hashtable['Bajarkot'] = ["19.519073", "85.224434"];
    hashtable['Satpara'] = ["19.668585", "85.44976"];
    hashtable['Arakhakud'] = ["19.714874", "85.582726"];
    hashtable['Puri'] = ["19.794329", "85.831627"];
    hashtable['Bangor'] = ["19.867941", "86.00679"];
    hashtable['Chandrabhaga'] = ["19.866081", "86.110863"];
    hashtable['Tondahar'] = ["19.903296", "86.223129"];
    hashtable['Balipantala'] = ["19.94006348", "86.29271698"];
    hashtable['Nuagar'] = ["19.971262", "86.327713"];
    hashtable['Magarkhia'] = ["20.006592", "86.364723"];
    hashtable['Saharabedi'] = ["20.075531", "86.45816"];
    hashtable['Nuagan'] = ["20.21773", "86.534714"];
    hashtable['Paradip'] = ["20.251488", "86.658188"];
    hashtable['Kharnasi'] = ["20.350643", "86.689598"];
    hashtable['False_Point'] = ["20.32915115", "86.74177551"];
    hashtable['Jambu'] = ["20.408928", "86.711166"];
    hashtable['Barunie'] = ["20.48403168", "86.73626709"];
    hashtable['Gajarajpur'] = ["20.542353", "86.774055"];
    hashtable['Hariharpur'] = ["20.609022", "86.839821"];
    hashtable['Satbhaya'] = ["20.63744", "86.933975"];
    hashtable['Talachua'] = ["20.79499626", "86.88869476"];
    hashtable['Dhamra'] = ["20.794996", "86.888695"];
    hashtable['Karanpalli'] = ["20.946985", "86.880066"];
    hashtable['Chudamani'] = ["21.16993332", "86.79206085"];
    hashtable['Janipur'] = ["21.285526", "86.880066"];
    hashtable['Chandipur'] = ["	21.442055", "87.026337"];
    hashtable['Balaramgadi'] = ["21.50081635", "87.05316162"];
    hashtable['Bahabalpur'] = ["21.51269913", "87.11349487"];
    hashtable['Bindha'] = ["21.558079", "87.140259"];
    hashtable['Kasafala'] = ["21.57311058", "87.20254517"];
    hashtable['Chandeneswar'] = ["21.61595345", "87.45111084"];
    //gujarath landing centers
    hashtable['Kanoj'] = ["23.673243", "	68.569214"];
    hashtable['Guvar'] = ["23.636499", "	68.539749"];
    hashtable['Lakhi_Bandar'] = ["23.594116", "	68.504883"];
    hashtable['Bhutau'] = ["23.541447", "68.489433"];
    hashtable['Moti_Akri'] = ["23.384974", "	68.605873"];
    hashtable['Mitha_Port'] = ["23.236032", "68.604362"];
    hashtable['Kadoli'] = ["23.071348", "68.827248"];
    hashtable['Khuada'] = ["22.996181", "68.949791"];
    hashtable['Chhachhi'] = ["22.950794", "69.000755"];
    hashtable['Bambhdai'] = ["22.937449", "69.089951"];
    hashtable['Bhada'] = ["22.850384", "69.206383"];
    hashtable['Kanthada'] = ["22.840059", "69.275024"];
    hashtable['Mandvi'] = ["22.82514", "69.34864"];
    hashtable['Rawal_Pir_Dargah'] = ["22.812149", "69.391586"];
    hashtable['Tunda'] = ["	22.828733", "69.535934"];
    hashtable['Mundra'] = ["22.73750305", "69.71215057"];
    hashtable['Luni'] = ["22.868034", "69.813011"];
    hashtable['Kukadsar'] = ["22.907656", "69.938789"];
    hashtable['Tekra'] = ["22.924372", "70.121841"];
    hashtable['Kandla'] = ["22.95965", "70.266304"];
    hashtable['Navalkhi'] = ["22.92240334", "70.41329956"];
    hashtable['Dabar_Cr'] = ["22.723169", "70.280319"];
    hashtable['Balachadi'] = ["22.597361", "	70.218025"];
    hashtable['Sachana'] = ["22.562988", "70.184601"];
    hashtable['Kalyan_Lt'] = ["22.592093", "	70.045654"];
    hashtable['Piroton_Island'] = ["22.600769", "69.951492"];
    hashtable['Sikka'] = ["22.4262085", "22.4262085"];
    hashtable['Salaaya'] = ["22.335844", "69.632607"];
    hashtable['Mota_Asota'] = ["22.267628", "69.372772"];
    hashtable['Poshitra'] = ["22.390995", "69.173325"];
    hashtable['Okha'] = ["22.474918", "69.068871"];
    hashtable['Kachchigadh'] = ["22.328226", "68.949196"];
    hashtable['Dwarka'] = ["22.237926", "68.959618"];
    hashtable['Kuranga'] = ["22.038656", "69.164696"];
    hashtable['Navadra'] = ["21.939524", "69.232025"];
    hashtable['Harshad_Miyani'] = ["21.832798", "69.381042"];
    hashtable['Tukda_Miyani'] = ["21.789511", "69.426323"];
    hashtable['Raatadi'] = ["21.729086", "69.492088"];
    hashtable['Kuchhadi'] = ["21.674345", "69.548866"];
    hashtable['Porbandar'] = ["21.620327", "69.616554"];
    hashtable['odadar'] = ["21.572197", "69.667107"];
    hashtable['Navibandar'] = ["21.521769", "69.716339"];
    hashtable['Gorsar'] = ["21.327284", "69.899261"];
    hashtable['Madhavpur'] = ["21.250832", "69.957481"];
    hashtable['Mangrol'] = ["21.104731", "70.106117"];
    hashtable['Chorwad'] = ["21.001663", "70.22773"];
    hashtable['Adri'] = ["20.960152", "70.289902"];
    hashtable['Veraval'] = ["20.905783", "70.35408"];
    hashtable['Kadwar'] = ["20.849394", "70.449821"];
    hashtable['Vadodra'] = ["20.814228", "70.523918"];
    hashtable['Mul_Dwarka'] = ["20.758497", "70.666168"];
    hashtable['Nava_Bandar'] = ["20.735836", "71.082176"];
    hashtable['Simar'] = ["	20.771328", "71.152611"];
    hashtable['Saiyad_Rajpara'] = ["20.787888", "71.208321"];
    hashtable['Kotda'] = ["	20.705082", "70.865257"];
    hashtable['Diu_Island'] = ["20.709465", "70.997368"];
    hashtable['Rohisa'] = ["20.82169", "71.252663"];
    hashtable['Jafarabad'] = ["20.853096", "	71.380096"];
    hashtable['Pipavav'] = ["20.899029", "71.529236"];
    hashtable['Patva'] = ["	21.000988", "71.652649"];
    hashtable['Gadhada'] = ["	21.022585", "71.75399"];
    hashtable['Mahuva'] = ["	21.037754", "71.80452"];
    hashtable['Nikol'] = ["	21.099493", "71.857849"];
    hashtable['Methla'] = ["	21.157148", "72.012383"];
    hashtable['Jhanjhmer'] = ["	21.178034", "72.063271"];
    hashtable['Gopnath'] = ["21.201626", "72.112144"];
    hashtable['Sartanpar'] = ["21.302366", "72.096474"];
    hashtable['Alang'] = ["21.400991", "72.186539"];
    hashtable['Mithi_Virdi'] = ["21.485449", "72.242744"];
    hashtable['Haathab'] = ["21.593037", "72.270416"];
    hashtable['Piram_Bet'] = ["	21.596048", "72.351486"];
    hashtable['Ghogha'] = ["21.688776", "72.279251"];
    hashtable['Bhavanagar_New_Port'] = ["21.77619171", "72.23344421"];
    hashtable['Dungariya_Bet'] = ["21.808481", "72.214211"];
    hashtable['Kamatalav'] = ["22.318459", "72.269691"];
    hashtable['Vadgam'] = ["22.323139", "72.42746"];
    hashtable['Khambat'] = ["22.30423927", "72.57226563"];
    hashtable['Sarod'] = ["22.165909", "72.747665"];
    hashtable['Gangeshwar'] = ["22.166914", "72.563301"];
    hashtable['Tankari_Pt'] = ["21.914629", "72.550583"];
    hashtable['Nadiyad'] = ["22.028606", "72.726097"];
    hashtable['Denwa'] = ["21.935095", "72.723228"];
    hashtable['Luhara_Pt'] = ["21.656193", "72.549866"];
    hashtable['Mehgam'] = ["21.670986", "72.760956"];
    hashtable['Dhanturia'] = ["21.66662", "72.867332"];
    hashtable['Oil_Derrick'] = ["21.514694", "72.554176"];
    hashtable['Wansnoli'] = ["21.546312", "72.771378"];
    hashtable['Kanthiajal'] = ["21.461903", "72.67794"];
    hashtable['Karanj'] = ["21.412781", "72.680099"];
    hashtable['Marphalia'] = ["21.261612", "	72.646675"];
    hashtable['Hazira'] = ["21.089025", "72.645096"];
    hashtable['Bhimpur'] = ["21.076897", "72.730415"];
    hashtable['Dipla'] = ["	20.996939", "72.738678"];
    hashtable['Wasi_Borsi'] = ["20.937166", "72.757431"];
    hashtable['Dandi'] = ["20.888235", "72.802284"];
    hashtable['Machhiwada'] = ["20.802755", "72.832329"];
    hashtable['Mendhar'] = ["20.759172", "72.872368"];
    hashtable['Valsad'] = ["20.628971", "72.888031"];
    hashtable['Bhimpor'] = ["20.453302", "72.846848"];
    hashtable['Daman'] = ["20.406881", "72.830536"];
    hashtable['Kalai'] = ["20.361488", "72.822769"];
    hashtable['Maroli'] = ["20.300463", "72.776627"];
    hashtable['Nargol'] = ["20.228584", "72.746941"];
    hashtable['Umargam'] = ["20.194162", "72.747879"];

    //maharatstra landing centers


    hashtable['Bordi'] = ["20.117968", "72.740112"];
    hashtable['Gholvad'] = ["20.08334", "72.729691"];
    hashtable['Khondha_Cr'] = ["19.973627", "72.716255"];
    hashtable['Tarapur_Pt'] = ["19.841747", "72.660553"];
    hashtable['Navapur_(Ucheli_Cr)'] = ["19.790586", "72.691093"];
    hashtable['Satpati'] = ["19.717438", "72.70475"];
    hashtable['Mahim_Cr'] = ["19.598286", "72.738892"];
    hashtable['Arnalapada'] = ["19.45314", "72.74752"];
    hashtable['Vasai'] = ["	19.32037735", "72.82122803"];
    hashtable['Dongi_Point'] = ["19.30479", "72.794235"];
    hashtable['Vesava'] = ["19.144012", "72.804298"];
    hashtable['Uarashi_Rf'] = ["19.070227", "72.814003"];
    hashtable['Malabar_Port_(Mumbai)'] = ["	18.93723297", "72.79360199"];
    hashtable['Colaba_Pt.(Mumbai)'] = ["18.87467", "	72.801422"];
    hashtable['Belapur'] = ["19.006823", "73.029053"];
    hashtable['Uran'] = ["18.875172", "72.932381"];
    hashtable['Karanja_Uran'] = ["18.83279991", "72.91600037"];
    hashtable['Bhalpada'] = ["18.783127", "73.01432"];
    hashtable['Avas'] = ["18.765669", "72.870209"];
    hashtable['Thal'] = ["18.684179", "72.864822"];
    hashtable['Alibag'] = ["18.64087677", "72.87341309"];
    hashtable['Nagaon'] = ["18.610189", "72.90255"];
    hashtable['Boghar'] = ["18.55056", "72.998146"];
    hashtable['Revadanda'] = ["18.53662872", "72.90814972"];
    hashtable['Korlai'] = ["18.524168", "72.915131"];
    hashtable['Mazgaon'] = ["18.372238", "72.939209"];
    hashtable['Murud'] = ["18.313395", "72.960625"];
    hashtable['Mandad'] = ["18.291588", "73.061752"];
    hashtable['Kudgaon'] = ["18.23494", "72.976227"];
    hashtable['Nanwell_Pt'] = ["18.276665", "72.938347"];
    hashtable['Diveagar'] = ["18.170027", "72.990242"];
    hashtable['Srivardhan'] = ["18.047529", "72.997284"];
    hashtable['Bankot'] = ["17.96931648", "73.04157257"];
    hashtable['Velas'] = ["17.958889", "73.036111"];
    hashtable['Kelsi'] = ["17.91736", "73.064629"];
    hashtable['Anjarle'] = ["17.850264", "73.090149"];
    hashtable['Harne'] = ["17.80509758", "73.08964539"];
    hashtable['Murud'] = ["17.767305", "73.122849"];
    hashtable['Burondi'] = ["17.699463", "73.137581"];
    hashtable['Kolthare'] = ["17.646069", "73.138664"];
    hashtable['Dabhol'] = ["17.585762", "73.177116"];
    hashtable['Tolkeshwar_Pt'] = ["17.561817", "73.143188"];
    hashtable['Guhagar'] = ["17.484749", "73.192207"];
    hashtable['Palshet'] = ["17.439749", "73.189911"];
    hashtable['Hedvi'] = ["17.355381", "73.225632"];
    hashtable['Jaigad'] = ["17.294722", "73.221667"];
    hashtable['Jaigarh_Head'] = ["17.294127", "73.190628"];
    hashtable['Kharviwada'] = ["17.187767", "73.243095"];
    hashtable['MTDC'] = ["17.14613", "73.268036"];
    hashtable['Kalabadevi'] = ["17.05386", "73.292831"];
    hashtable['Mirkarwada'] = ["16.99753571", "73.27963257"];
    hashtable['Ratnagiri'] = ["16.984549", "73.274361"];
    hashtable['Rajiwada-Kerla'] = ["16.982222", "73.298056"];
    hashtable['Purnagad'] = ["16.857778", "73.288333"];
    hashtable['Purangad'] = ["16.8088", "73.303474"];
    hashtable['Sakhri-Natye'] = ["16.81681633", "73.32343292"];
    hashtable['Mavlanga'] = ["16.833536", "73.34243"];
    hashtable['Bokarwadi'] = ["16.745264", "73.314034"];
    hashtable['Wada_Vetye'] = ["16.69055", "73.330925"];
    hashtable['Ambolgarh'] = ["16.637848", "73.327286"];
    hashtable['Wagapur_Pt'] = ["16.602047", "73.3218"];
    hashtable['Vijayadurg_Hr'] = ["16.558729", "73.33474"];
    hashtable['Kalamaiwadi'] = ["16.448994", "73.359322"];
    hashtable['Devgarh'] = ["16.386745", "73.373192"];
    hashtable['Kunkeshwar'] = ["16.33452", "73.392021"];
    hashtable['Munge'] = ["16.239422", "73.432991"];
    hashtable['Achra_Pt'] = ["16.196899", "73.43177"];
    hashtable['Hadi'] = ["16.14636", "73.471802"];
    hashtable['Sarjekot'] = ["16.079662", "73.463539"];
    hashtable['Sindhudurg_(Malvan)'] = ["16.038147", "73.457283"];
    hashtable['Vengurla'] = ["15.851094", "73.617561"];
    hashtable['Terekhol'] = ["15.727038", "73.67952"];
//kerala landing centers

    hashtable['Manjeshwara'] = ["12.713051", "74.892769"];
    hashtable['Kumbla'] = ["12.606485", "74.940567"];
    hashtable['Kasaragod'] = ["12.502532", "74.974922"];
    hashtable['Bekal'] = ["12.39781", "75.033646"];
    hashtable['Hosdrug'] = ["12.314081", "75.089348"];
    hashtable['Nileswaram'] = ["12.25966", "75.126007"];
    hashtable['Maniyat'] = ["12.181542", "75.162659"];
    hashtable['Kavvayi'] = ["12.091731", "75.178474"];
    hashtable['Kunnariyam'] = ["12.053182", "75.216568"];
    hashtable['Kotte_Kunnu'] = ["12.004907", "75.203842"];
    hashtable['Valapattanam'] = ["11.924404", "75.349174"];
    hashtable['Azhikal'] = ["11.941222", "75.302315"];
    hashtable['Kannur'] = ["11.869078", "75.355575"];
    hashtable['Tellicherry'] = ["11.743703", "75.485237"];
    hashtable['Mahe'] = ["11.700499", "75.530876"];
    hashtable['Uralungal'] = ["11.637618", "75.573784"];
    hashtable['Nalliyankara'] = ["11.616716", "75.583847"];
    hashtable['Badagara'] = ["11.594926", "75.581302"];
    hashtable['Puduppanam'] = ["11.574202", "75.609718"];
    hashtable['Kottakkal'] = ["11.555421", "75.604691"];
    hashtable['Tikkoti'] = ["11.486315", "75.621941"];
    hashtable['Kadalur_Pt'] = ["11.467007", "75.63797"];
    hashtable['Kollam'] = ["11.452287", "75.681236"];
    hashtable['Chemancheri'] = ["11.396627", "75.730469"];
    hashtable['Elattur'] = ["11.334929", "75.739456"];
    hashtable['Nadakkavu'] = ["11.274281", "75.776115"];
    hashtable['Calicut'] = ["11.257088", "75.769859"];
    hashtable['Ramanattukara'] = ["11.171398", "75.867393"];
    hashtable['Beypore'] = ["11.155618", "75.807953"];
    hashtable['Parappanangadi'] = ["11.04505", "75.867035"];
    hashtable['Tanur_Nagaram'] = ["10.982042", "75.867966"];
    hashtable['Paravannangadi'] = ["10.898758", "75.890396"];
    hashtable['Purattur'] = ["10.811019", "75.923096"];
    hashtable['Ponnani'] = ["10.773545", "75.920799"];
    hashtable['Veliyangod'] = ["10.72894", "75.948975"];
    hashtable['Vayilattur'] = ["10.635463", "76.016533"];
    hashtable['Chavakkad'] = ["10.549612", "76.018188"];
    hashtable['Mullassheri'] = ["10.529156", "76.085175"];
    hashtable['Edamuttam'] = ["10.364821", "76.12291"];
    hashtable['Kulimuttam'] = ["10.291162", "76.133331"];
    hashtable['Pullut'] = ["10.245606", "76.210236"];
    hashtable['Kodungallur'] = ["10.200588", "76.157265"];
    hashtable['Munambam'] = ["10.17548", "76.171425"];
    hashtable['Cherai'] = ["10.13484097", "76.19422913"];
    hashtable['Edvankad'] = ["10.09791088", "76.2053299"];
    hashtable['Narakkal'] = ["10.04411411", "76.2217865"];
    hashtable['Nayarambalam'] = ["10.03384876", "76.22036743"];
    hashtable['Malipuram'] = ["10.020933", "76.222458"];
    hashtable['Ernakulam'] = ["9.995475", "76.220871"];
    hashtable['Vypeen'] = ["9.982979774", "76.24158478"];
    hashtable['Valarpadam'] = ["9.990200996", "76.25138092"];
    hashtable['Kochi'] = ["9.960554123", "76.23849487"];
    hashtable['Chellanum'] = ["9.812498", "76.27816"];
    hashtable['Palithodu'] = ["9.778022766", "76.28134155"];
    hashtable['Manakkodam'] = ["9.74603", "76.286636"];
    hashtable['Aratungal'] = ["9.657064", "76.298286"];
    hashtable['Kottamkulangara'] = ["9.592873", "76.306549"];
    hashtable['Alleppey'] = ["9.492114", "76.320778"];
    hashtable['Kalarkod'] = ["9.465525", "76.343925"];
    hashtable['Punnappira'] = ["9.434125", "76.349312"];
    hashtable['Ambalapuzha'] = ["9.379108", "76.355637"];
    hashtable['Porakad'] = ["9.352403", "76.373032"];
    hashtable['Trikkunnapuzha'] = ["9.261024", "76.411842"];
    hashtable['Padiyamkara_Tekku'] = ["9.176762", "76.449219"];
    hashtable['Azhikal'] = ["9.113909", "76.475098"];
    hashtable['Alappattu'] = ["9.071763", "76.494499"];
    hashtable['Kovilthottam'] = ["8.984073", "76.524544"];
    hashtable['Chavara'] = ["8.964232", "76.539421"];
    hashtable['Neendakara'] = ["8.943933487", "76.5400238"];
    hashtable['Quilon'] = ["8.878303", "76.566231"];
    hashtable['Tanni'] = ["8.836296", "76.639328"];
    hashtable['Pozhikara'] = ["8.808773", "76.652985"];
    hashtable['Kappil'] = ["8.780534", "76.678146"];
    hashtable['Edaval'] = ["8.754079", "76.705093"];
    hashtable['Vettur'] = ["8.718327", "76.720192"];
    hashtable['Anjengo'] = ["8.671318", "76.756699"];
    hashtable['Perumatura'] = ["8.614253", "76.799622"];
    hashtable['Thumba'] = ["8.530212", "76.873642"];
    hashtable['Vell'] = ["8.505171", "76.897362"];
    hashtable['Trivandrum'] = ["8.476382", "76.918419"];
    hashtable['Tiruvallam'] = ["8.43934", "76.960609"];
    hashtable['Vilinjam'] = ["8.381561", "76.982033"];
    hashtable['Mariyanadu'] = ["8.365848541", "77.01259613"];
    hashtable['Karichal'] = ["8.347731", "77.036797"];
    hashtable['Puvar'] = ["8.316235", "77.074173"];
//tamilanadu landing centers
    hashtable['Marthandam_VKC'] = ["8.285292", "77.108238"];
    hashtable['Taingapatnam'] = ["8.233904", "77.17408"];
    hashtable['Kolachel'] = ["8.171082", "77.255875"];
    hashtable['Neerody'] = ["8.171273232", "77.28033447"];
    hashtable['Kovalam'] = ["8.139388084", "77.31375122"];
    hashtable['Muttom'] = ["8.132231712", "77.32156372"];
    hashtable['Kadiapattanam'] = ["8.122741", "77.318405"];
    hashtable['Rajakkamanglam'] = ["8.129354", "77.367424"];
    hashtable['Puttantura'] = ["8.102855", "77.421326"];
    hashtable['Keezhamanakudi'] = ["8.093569756", "77.49163818"];
    hashtable['Puthur'] = ["8.085043907", "77.53794098"];
    hashtable['Kanniyakumari'] = ["8.079351", "77.54734"];
    hashtable['Lipuram'] = ["8.112524", "77.557175"];
    hashtable['Chettikulam'] = ["8.15442", "77.620781"];
    hashtable['Kudangulam'] = ["8.187361", "77.709908"];
    hashtable['Kuttankuli'] = ["8.212781", "77.779266"];
    hashtable['Kundal'] = ["8.258963", "77.855812"];
    hashtable['Manappad_Pt'] = ["8.37011", "78.065186"];
    hashtable['Alantalai'] = ["8.462955", "78.099831"];
    hashtable['Virapandiyanpattinam'] = ["8.515546", "78.119591"];
    hashtable['Punnaikkayal'] = ["8.629645", "78.118515"];
    hashtable['Pandyan'] = ["8.780724", "78.198151"];
    hashtable['Tuticorin'] = ["8.797524", "78.161499"];
    hashtable['Pattanamarudur'] = ["8.918495", "78.182487"];
    hashtable['Veppalodai'] = ["8.970306", "78.189674"];
    hashtable['Vaippar'] = ["9.021752", "78.247528"];
    hashtable['Vembar'] = ["9.079978", "78.362892"];
    hashtable['Terku_Mukkaiyur'] = ["9.128909", "78.479332"];
    hashtable['Valinokkam'] = ["9.159621", "78.645363"];
    hashtable['Kilakarai'] = ["9.224798", "78.782135"];
    hashtable['Muttupettai'] = ["9.266378", "78.921715"];
    hashtable['Vanagapuri'] = ["9.27338", "78.97081"];
    hashtable['Seeniyappa_tharya'] = ["9.26149", "79.068687"];
    hashtable['Mandapam'] = ["9.273708", "79.144386"];
    hashtable['Pamban_kunthukal'] = ["9.259153", "79.223061"];
    hashtable['Dhanushkodi'] = ["9.200273", "79.379936"];
    hashtable['Olaikuda'] = ["9.266220093", "79.32678986"];
    hashtable['Verkode'] = ["9.276847839", "79.31726837"];
    hashtable['Rameswaram_harbour'] = ["9.281157", "79.315163"];
    hashtable['Viloondi'] = ["9.29237", "79.262383"];
    hashtable['Thangachimadam'] = ["9.285012245", "79.25888824"];
    hashtable['Pamban_lht'] = ["9.289227", "79.218834"];
    hashtable['Mandapam_jetty'] = ["9.285939", "79.158836"];
    hashtable['Attangarai'] = ["9.342052", "78.994308"];
    hashtable['Devipattinam'] = ["9.471856117", "78.89359283"];
    hashtable['Moreppanai'] = ["9.608565", "78.930702"];
    hashtable['Tiruvettriyur'] = ["9.705199", "78.946159"];
    hashtable['Tondi'] = ["9.739781", "79.015152"];
    hashtable['Sundarapandiyanpatta'] = ["9.841366", "79.094574"];
    hashtable['Gopalapatnam'] = ["9.922968", "79.147766"];
    hashtable['Kottaippattanam'] = ["9.973557", "79.193764"];
    hashtable['Manamelkudi'] = ["10.039454", "79.23114"];
    hashtable['Prataparamanpattinam'] = ["10.102489", "79.221436"];
    hashtable['Setubavachattram'] = ["10.245963", "79.274261"];
    hashtable['Atirampattinam'] = ["10.34029579", "79.38010406"];
    hashtable['Muthupet'] = ["10.392833", "79.496228"];
    hashtable['Point_Calimere'] = ["10.289215", "79.865654"];
    hashtable['Vedaranniyam'] = ["10.376562", "79.842796"];
    hashtable['Topputturai'] = ["10.402534", "79.847824"];
    hashtable['Akkaraipettai'] = ["10.44097614", "79.86642456"];
    hashtable['Kallinodu'] = ["10.490747", "79.825188"];
    hashtable['Vellapallam'] = ["10.519905", "79.861679"];
    hashtable['Vettaikaranrippu'] = ["10.57056", "79.846771"];
    hashtable['Kameshwaram'] = ["10.621675", "79.854996"];
    hashtable['Serugur'] = ["10.673811", "79.85363"];
    hashtable['Velanganni'] = ["10.692258", "79.849846"];
    hashtable['Nagappattinam'] = ["10.763597", "79.851997"];
    hashtable['Nagore'] = ["10.80544", "79.846222"];
    hashtable['Karikal'] = ["10.913152", "79.854149"];
    hashtable['Pattinacherry'] = ["10.93326569", "79.85255432"];
    hashtable['Tranquebar'] = ["11.025841", "79.84848"];
    hashtable['Chinnangudi'] = ["11.05286789", "79.85788727"];
    hashtable['Poombuhar'] = ["11.07529354", "79.85788727"];
    hashtable['Thalampettai'] = ["11.082793", "79.85704"];
    hashtable['Kaverippattinam'] = ["11.128577", "79.857574"];
    hashtable['Tirumullaivasal'] = ["11.247868", "79.840309"];
    hashtable['Mudasalodai_Village'] = ["11.27925777", "79.84082794"];
    hashtable['Parangipettai'] = ["11.2995472", "79.8376236"];
    hashtable['Samiyarpettai_Village'] = ["11.3187685", "79.83655548"];
    hashtable['Pazhayar'] = ["11.35880566", "79.82405853"];
    hashtable['Pudukuppam'] = ["11.407698", "79.818619"];
    hashtable['Panithittu'] = ["11.48962879", "79.78322601"];
    hashtable['Portonovo'] = ["11.502451", "79.769699"];
    hashtable['Pudukuppam'] = ["11.526945", "79.766388"];
    hashtable['Veerampatinam'] = ["11.53661537", "79.76083374"];
    hashtable['Samanthapettai'] = ["11.54908466", "79.75817108"];
    hashtable['Kumarapettai'] = ["11.55693", "79.759033"];
    hashtable['Periyakuppam'] = ["11.603881", "79.758049"];
    hashtable['Chitharaipettai'] = ["11.638133", "79.763611"];
    hashtable['Cuddalore'] = ["11.704041", "79.777245"];
    hashtable['Thengaithittu'] = ["11.76768494", "79.79386902"];
    hashtable['Murthipudukuppam'] = ["11.789429", "79.796661"];
    hashtable['Nallavadu'] = ["11.856487", "79.814735"];
    hashtable['ChinnaVeerampattinam'] = ["11.882415", "79.824829"];
    hashtable['Pondicherry'] = ["11.913621", "79.832947"];
    hashtable['Vaithikuppam'] = ["11.943899", "79.837311"];
    hashtable['Solainagar_North'] = ["11.956387", "79.840546"];
    hashtable['Pillaichavadi'] = ["12.00602", "79.857529"];
    hashtable['Ganapathichettikulam'] = ["12.03946", "79.873177"];
    hashtable['Malakkanam'] = ["12.192305", "79.952965"];
    hashtable['Cheyyur'] = ["12.35043", "80.010193"];
    hashtable['Sadras'] = ["12.519614", "80.160538"];
    hashtable['Mahabalipuram'] = ["12.611612", "80.191963"];
    hashtable['Covelong_(Kovalam)'] = ["12.782319", "80.250931"];
    hashtable['Thiruvanmiyur'] = ["12.98341656", "80.2666626"];
    hashtable['Cathedral_(Chennai)'] = ["13.038652", "80.27462"];
    hashtable['Chennai'] = ["13.117209", "80.295464"];
    hashtable['Royapuram'] = ["13.13201904", "80.29945374"];
    hashtable['Ennur'] = ["13.246252", "80.329391"];
    hashtable['Pulicat'] = ["13.420277", "80.32457"];
    hashtable['Coromandel'] = ["13.4521", "80.30603"];
//Andhra landing centers
    hashtable['Pulinjerikuppam'] = ["13.606457", "80.248169"];
    hashtable['Durgarajupatnam'] = ["13.978038", "80.156174"];
    hashtable['Kondur'] = ["14.015233", "80.125267"];
    hashtable['Arkatapalem'] = ["14.07011986", "80.13576508"];
    hashtable['Kottapatnam'] = ["14.118365", "80.120232"];
    hashtable['Tammenapatnam'] = ["14.228812", "80.105499"];
    hashtable['Krishnapatnam(Upputeru)'] = ["14.250363", "80.129143"];
    hashtable['Krishnapatnam'] = ["14.28419", "80.125984"];
    hashtable['Pathapalem'] = ["14.393153", "80.170906"];
    hashtable['Maipadu'] = ["14.506264", "80.167313"];
    hashtable['Utukuru'] = ["14.574872", "80.140358"];
    hashtable['Pattapupalem'] = ["14.63978672", "80.14537048"];
    hashtable['Isakapalle'] = ["14.733008", "80.095795"];
    hashtable['Zuvvaladinne'] = ["14.80326843", "80.0729599"];
    hashtable['Vatturupallepalem'] = ["14.84734", "80.086449"];
    hashtable['Ramayapatnam'] = ["15.04283", "80.056839"];
    hashtable['Chakicherla'] = ["15.105146", "80.041168"];
    hashtable['Itamukkala'] = ["15.36854076", "80.11911774"];
    hashtable['Allurukottapatnam'] = ["15.439334", "80.161201"];
    hashtable['Adavipallipalem'] = ["15.48095703", "80.2098465"];
    hashtable['Vetapalem'] = ["15.777501", "80.303871"];
    hashtable['Vadarevu'] = ["15.798379", "80.420311"];
    hashtable['Bestapalam_Bapatla'] = ["15.82503319", "80.47181702"];
    hashtable['Suryalanka'] = ["15.84708405", "80.5270462"];
    hashtable['Nizampatnam'] = ["15.876138", "80.641899"];
    hashtable['Nachugunta'] = ["15.782025", "80.890373"];
    hashtable['Etimoga'] = ["15.784729", "80.98582458"];
    hashtable['Sorlagondi'] = ["15.85074139", "81.01898956"];
    hashtable['Palakayatippa'] = ["15.98569012", "81.14788818"];
    hashtable['Machilipatnam'] = ["16.151058", "81.182037"];
    hashtable['Giripuram'] = ["16.23354149", "81.2331543"];
    hashtable['Pedda_Gollapalem'] = ["16.367828", "81.442734"];
    hashtable['Narasapur_Pt'] = ["16.31423", "81.72757"];
    hashtable['Bandamurlanka'] = ["16.444139", "81.97892"];
    hashtable['Karakutippa'] = ["16.582989", "82.279572"];
    hashtable['Bhairavapalem'] = ["16.84923744", "82.34700775"];
    hashtable['Kakinada'] = ["16.948582", "82.278137"];
    hashtable['Vakalapudi'] = ["17.011518", "82.284599"];
    hashtable['Uppada'] = ["17.08297348", "82.33384705"];
    hashtable['Konapapeta'] = ["17.1333828", "82.38301086"];
    hashtable['Perumallanuram'] = ["17.178259", "82.433884"];
    hashtable['Danavaipeta'] = ["17.22010231", "82.49021912"];
    hashtable['Pentakota'] = ["17.298267", "82.618103"];
    hashtable['Revu_Polavaram'] = ["17.398169", "82.807999"];
    hashtable['Rambilli'] = ["17.457502", "82.935211"];
    hashtable['Pudimadaka'] = ["17.485966", "83.005508"];
    hashtable['Palmanpeta'] = ["17.67053795", "83.29082489"];
    hashtable['Visakhapatnam'] = ["17.673811", "83.295883"];
    hashtable['Bhimunipatnam'] = ["17.888298", "83.457245"];
    hashtable['Mukkam'] = ["17.986837", "83.555496"];
    hashtable['Konada'] = ["18.01572", "83.564835"];
    hashtable['Chintapalli'] = ["18.062654", "83.640884"];
    hashtable['Ramachandrapuram'] = ["18.109558", "83.71685"];
    hashtable['Allivalasa'] = ["18.121241", "83.739853"];
    hashtable['Kuppili'] = ["18.172775", "83.810287"];
    hashtable['Srikurmam'] = ["18.265497", "84.006508"];
    hashtable['Kalingapatnam'] = ["18.339134", "84.124962"];
    hashtable['Gupparapeta'] = ["18.40929", "84.185478"];
    hashtable['Jagannadhapuram'] = ["18.436386", "84.213867"];
    hashtable['Maruvada'] = ["18.487141", "84.269928"];
    hashtable['Kotta_Naupada'] = ["18.555017", "84.301918"];
    hashtable['Bavanapadu'] = ["18.566326", "84.354744"];
    hashtable['Nuvvalarevu'] = ["18.681782", "84.442787"];
    hashtable['Metturu'] = ["18.75985", "84.512146"];
    hashtable['Ganguvada'] = ["18.783468", "84.543419"];
    hashtable['Baruva'] = ["18.877407", "84.595383"];
    hashtable['Iduvanipalem'] = ["18.969219", "84.685005"];
    hashtable['Kaviti'] = ["19.005455", "84.690041"];
    hashtable['Sonnapurampeta'] = ["19.109674", "84.777008"];



    $("#latlong_no").hide();
    $("#ddtodms").hide();
    $("input[name=latlong_know]").click(function () {
        var latlong_know = $(this).val();
        if (latlong_know === "latlong_no")
        {
//map_mouse_Enable();
            $("#traveled_distance").attr('required', true);
            $("#angle").attr('required', true);
            $("#landingcenter").attr('required', true);
            $("#ddtodms").hide();
            $("#" + latlong_know).show();
            $("#dddms_radio").hide();
            $("input[name=latitude]").attr('readonly', true);
            $("input[name=longitude]").attr('readonly', true);
        }
        else {
            $("#traveled_distance").removeAttr('required');
            $("#angle").removeAttr('required');
            $("#landingcenter").removeAttr('required');
            $('#latlong-0').prop('checked', true);
            $("#latlong_no").hide();
            $("#dddms_radio").show();
            $("input[name=latitude]").removeAttr('readonly');
            $("input[name=longitude]").removeAttr('readonly');
        }
    });
    $("input[name=latlong]").click(function () {
        var latlong_in = $(this).val();
        $("#traveled_distance").removeAttr('required');
        $("#angle").removeAttr('required');
        $("#landingcenter").removeAttr('required');
        if (latlong_in === "dms")
        {
            $("#ddtodms").show();
            $("input[name=latitude]").attr('readonly', true);
            $("input[name=longitude]").attr('readonly', true);
        }
        if (latlong_in === "dd") {
            $("#ddtodms").hide();
            $("input[name=latitude]").removeAttr('readonly');
            $("input[name=longitude]").removeAttr('readonly');
        }
    });
    //});
    var Karnataka = [
        {display: "Mangalore", value: "Mangalore"},
        {display: "New Mangalore", value: "New_Mangalore"},
        {display: "Suratkal pt", value: "Suratkal_pt"},
        {display: "Mulki", value: "Mulki"},
        {display: "Kapu", value: "Kapu"},
        {display: "Udyavara", value: "Udyavara"},
        {display: "Malpe", value: "Malpe"},
        {display: "Hangarkatta", value: "Hangarkatta"},
        {display: "Kota", value: "Kota"},
        {display: "Coondapur", value: "Coondapur"},
        {display: "Gangoli", value: "Gangoli"},
        {display: "Navunda", value: "Navunda"},
        {display: "Baindur", value: "Baindur"},
        {display: "Bhatkal", value: "Bhatkal"},
        {display: "Shirali", value: "Shirali"},
        {display: "Mavalli", value: "Mavalli"},
        {display: "Navayatkere", value: "Navayatkere"},
        {display: "Kasarkod", value: "Kasarkod"},
        {display: "Honavar", value: "Honavar"},
        {display: "Karki", value: "Karki"},
        {display: "Dhareshvar", value: "Dhareshvar"},
        {display: "Kumta Pt", value: "Kumta Pt"},
        {display: "Tadri", value: "Tadri"},
        {display: "Gangavali", value: "Gangavali"},
        {display: "Belekeri", value: "Belekeri"},
        {display: "Karwar", value: "Karwar"},
        {display: "Sadasguvgarg", value: "Sadasguvgarg"},
    ];
    var Andhra = [
        {display: "Pulinjerikuppam", value: "Pulinjerikuppam"},
        {display: "Durgarajupatnam", value: "Durgarajupatnam"},
        {display: "Kondur", value: "Kondur"},
        {display: "Arkatapalem", value: "Arkatapalem"},
        {display: "Kottapatnam", value: "Kottapatnam"},
        {display: "Tammenapatnam", value: "Tammenapatnam"},
        {display: "Krishnapatnam(Upputeru)", value: "Krishnapatnam(Upputeru)"},
        {display: "Krishnapatnam", value: "Krishnapatnam"},
        {display: "Pathapalem", value: "Pathapalem"},
        {display: "Maipadu", value: "Maipadu"},
        {display: "Utukuru", value: "Utukuru"},
        {display: "Pattapupalem", value: "Pattapupalem"},
        {display: "Isakapalle", value: "Isakapalle"},
        {display: "Zuvvaladinne", value: "Zuvvaladinne"},
        {display: "Vatturupallepalem", value: "Vatturupallepalem"},
        {display: "Ramayapatnam", value: "Ramayapatnam"},
        {display: "Chakicherla", value: "Chakicherla"},
        {display: "Itamukkala", value: "Itamukkala"},
        {display: "Allurukottapatnam", value: "Allurukottapatnam"},
        {display: "Adavipallipalem", value: "Adavipallipalem"},
        {display: "Vetapalem", value: "Vetapalem"},
        {display: "Vadarevu", value: "Vadarevu"},
        {display: "Bestapalam_Bapatla", value: "Bestapalam_Bapatla"},
        {display: "Suryalanka", value: "Suryalanka"},
        {display: "Nizampatnam", value: "Nizampatnam"},
        {display: "Nachugunta", value: "Nachugunta"},
        {display: "Etimoga", value: "Etimoga"},
        {display: "Sorlagondi", value: "Sorlagondi"},
        {display: "Palakayatippa", value: "Palakayatippa"},
        {display: "Machilipatnam", value: "Machilipatnam"},
        {display: "Giripuram", value: "Giripuram"},
        {display: "Pedda_Gollapalem", value: "Pedda_Gollapalem"},
        {display: "Narasapur_Pt", value: "Narasapur_Pt"},
        {display: "Bandamurlanka", value: "Bandamurlanka"},
        {display: "Karakutippa", value: "Karakutippa"},
        {display: "Bhairavapalem", value: "Bhairavapalem"},
        {display: "Kakinada", value: "Kakinada"},
        {display: "Vakalapudi", value: "Vakalapudi"},
        {display: "Uppada", value: "Uppada"},
        {display: "Konapapeta", value: "Konapapeta"},
        {display: "Perumallanuram", value: "Perumallanuram"},
        {display: "Danavaipeta", value: "Danavaipeta"},
        {display: "Pentakota", value: "Pentakota"},
        {display: "Revu_Polavaram", value: "Revu_Polavaram"},
        {display: "Rambilli", value: "Rambilli"},
        {display: "Pudimadaka", value: "Pudimadaka"},
        {display: "Palmanpeta", value: "Palmanpeta"},
        {display: "Visakhapatnam", value: "Visakhapatnam"},
        {display: "Bhimunipatnam", value: "Bhimunipatnam"},
        {display: "Mukkam", value: "Mukkam"},
        {display: "Konada", value: "Konada"},
        {display: "Chintapalli", value: "Chintapalli"},
        {display: "Ramachandrapuram", value: "Ramachandrapuram"},
        {display: "Allivalasa", value: "Allivalasa"},
        {display: "Kuppili", value: "Kuppili"},
        {display: "Srikurmam", value: "Srikurmam"},
        {display: "Kalingapatnam", value: "Kalingapatnam"},
        {display: "Gupparapeta", value: "Gupparapeta"},
        {display: "Jagannadhapuram", value: "Jagannadhapuram"},
        {display: "Maruvada", value: "Maruvada"},
        {display: "Kotta_Naupada", value: "Kotta_Naupada"},
        {display: "Bavanapadu", value: "Bavanapadu"},
        {display: "Nuvvalarevu", value: "Nuvvalarevu"},
        {display: "Metturu", value: "Metturu"},
        {display: "Ganguvada", value: "Ganguvada"},
        {display: "Baruva", value: "Baruva"},
        {display: "Iduvanipalem", value: "Iduvanipalem"},
        {display: "Kaviti", value: "Kaviti"},
        {display: "Sonnapurampeta", value: "Sonnapurampeta"}
    ];
    var Goa = [
        {display: "Chapora", value: "Aguada"},
        {display: "Aguada", value: "Aguada"},
        {display: "Panaji_(Malim)", value: "Panaji_(Malim)"},
        {display: "Santerem_Pt_(Vasco)", value: "Santerem_Pt_(Vasco)"},
        {display: "Majorde", value: "Majorde"},
        {display: "Fatarde", value: "Fatarde"},
        {display: "Betul", value: "Betul"},
        {display: "Cutbona", value: "Cutbona"},
        {display: "Talpona", value: "Talpona"},
        {display: "Kolamb", value: "Kolamb"}
    ];
    var West_bengal = [
        {display: "Digha", value: "Digha"},
        {display: "Shankarpur", value: "Shankarpur"},
        {display: "Petuaghat_(Dariapur)", value: "Petuaghat_(Dariapur)"},
        {display: "Diamond_Harbour", value: "Diamond_Harbour"},
        {display: "Kakdwip", value: "Kakdwip"},
        {display: "Namkhana", value: "Namkhana"},
        {display: "Sagar", value: "Sagar"},
        {display: "Frasergunje", value: "Frasergunje"},
    ];
    var andaman = [
        {display: "Landfall", value: "Landfall"},
        {display: "Diglipur", value: "Diglipur"},
        {display: "Mayabunder", value: "Mayabunder"},
        {display: "Elphinstone_Hr", value: "Elphinstone_Hr"},
        {display: "Middle_Strait", value: "Middle_Strait"},
        {display: "Port_Blair", value: "Port_Blair"},
        {display: "Mt_Haughton", value: "Mt_Haughton"},
        {display: "Rutland", value: "Rutland"},
        {display: "Cinque_Island", value: "Cinque_Island"},
        {display: "Neil_Island", value: "Neil_Island"},
        {display: "Barren", value: "Barren"},
        {display: "Narcondam", value: "Narcondam"},
        {display: "Tambe-e-bul", value: "Tambe-e-bul"},
        {display: "Kwate-tu-Kwage", value: "Kwate-tu-Kwage"},
        {display: "Benyaboi", value: "Benyaboi"},
        {display: "Tula", value: "Tula"},
        {display: "Tochangeou", value: "Tochangeou"},
    ];
    var lakshadweep = [
        {display: "Valiyapani_reef", value: "Valiyapani_reef"},
        {display: "Byramgore", value: "Byramgore"},
        {display: "Cheriyapani_reef", value: "Cheriyapani_reef"},
        {display: "Chetlat_I", value: "Chetlat_I"},
        {display: "Bitra_I", value: "Bitra_I"},
        {display: "Kiltani", value: "Kiltani"},
        {display: "Perumalpar_reef", value: "Perumalpar_reef"},
        {display: "Kadmath_I", value: "Kadmath_I"},
        {display: "Amini_I", value: "Amini_I"},
        {display: "Tinnakara", value: "Tinnakara"},
        {display: "Bangaram_I", value: "Bangaram_I"},
        {display: "Agatti_I", value: "Agatti_I"},
        {display: "Androth_I", value: "Androth_I"},
        {display: "Kavaratti_I", value: "Kavaratti_I"},
        {display: "Valiykara", value: "Valiykara"},
        {display: "Suheli", value: "Suheli"},
        {display: "Cheriyakara", value: "Cheriyakara"},
        {display: "Kalpeni_I", value: "Kalpeni_I"},
        {display: "Minicoy", value: "Minicoy"},
    ];
    var odissa = [
        {display: "Ekasingi", value: "Ekasingi"},
        {display: "New_Golabandha", value: "New_Golabandha"},
        {display: "Gopalpur", value: "Gopalpur"},
        {display: "Sana_Aryapalli", value: "Sana_Aryapalli"},
        {display: "Ganjam", value: "Ganjam"},
        {display: "Bajarkot", value: "Bajarkot"},
        {display: "Satpara", value: "Satpara"},
        {display: "Arakhakud", value: "Arakhakud"},
        {display: "Puri", value: "Puri"},
        {display: "Bangor", value: "Bangor"},
        {display: "Chandrabhaga", value: "Chandrabhaga"},
        {display: "Tondahar", value: "Tondahar"},
        {display: "Balipantala", value: "Balipantala"},
        {display: "Nuagar", value: "Nuagar"},
        {display: "Magarkhia", value: "Magarkhia"},
        {display: "Saharabedi", value: "Saharabedi"},
        {display: "Nuagan", value: "Nuagan"},
        {display: "Paradip", value: "Paradip"},
        {display: "Kharnasi", value: "Kharnasi"},
        {display: "False_Point", value: "False_Point"},
        {display: "Jambu", value: "Jambu"},
        {display: "Barunie", value: "Barunie"},
        {display: "Gajarajpur", value: "Gajarajpur"},
        {display: "Hariharpur", value: "Hariharpur"},
        {display: "Satbhaya", value: "Satbhaya"},
        {display: "Talachua", value: "Talachua"},
        {display: "Dhamra", value: "Dhamra"},
        {display: "Karanpalli", value: "Karanpalli"},
        {display: "Chudamani", value: "Chudamani"},
        {display: "Janipur", value: "Janipur"},
        {display: "Chandipur", value: "Chandipur"},
        {display: "Balaramgadi", value: "Balaramgadi"},
        {display: "Bahabalpur", value: "Bahabalpur"},
        {display: "Bindha", value: "Bindha"},
        {display: "Kasafala", value: "Kasafala"},
        {display: "Chandeneswar", value: "Chandeneswar"}
    ];
    var gujarath = [
        {display: "Kanoj", value: "Kanoj"},
        {display: "Guvar", value: "Guvar"},
        {display: "Lakhi_Bandar", value: "Lakhi_Bandar"},
        {display: "Bhutau", value: "Bhutau"},
        {display: "Moti_Akri", value: "Moti_Akri"},
        {display: "Mitha_Port", value: "Mitha_Port"},
        {display: "Kadoli", value: "Kadoli"},
        {display: "Khuada", value: "Khuada"},
        {display: "Chhachhi", value: "Chhachhi"},
        {display: "Bambhdai", value: "Bambhdai"},
        {display: "Bhada", value: "Bhada"},
        {display: "Kanthada", value: "Kanthada"},
        {display: "Mandvi", value: "Mandvi"},
        {display: "Rawal_Pir_Dargah", value: "Rawal_Pir_Dargah"},
        {display: "Tunda", value: "Tunda"},
        {display: "Mundra", value: "Mundra"},
        {display: "Luni", value: "Luni"},
        {display: "Kukadsar", value: "Kukadsar"},
        {display: "Tekra", value: "Tekra"},
        {display: "Kandla", value: "Kandla"},
        {display: "Navalkhi", value: "Navalkhi"},
        {display: "Dabar_Cr", value: "Dabar_Cr"},
        {display: "Balachadi", value: "Balachadi"},
        {display: "Sachana", value: "Sachana"},
        {display: "Kalyan_Lt", value: "	Kalyan_Lt"},
        {display: "Piroton_Island", value: "Piroton_Island"},
        {display: "Sikka", value: "Sikka"},
        {display: "Salaaya", value: "Salaaya"},
        {display: "Mota_Asota", value: "Mota_Asota"},
        {display: "Poshitra", value: "Poshitra"},
        {display: "Okha", value: "Okha"},
        {display: "Kachchigadh", value: "Kachchigadh"},
        {display: "Dwarka", value: "Dwarka"},
        {display: "Kuranga", value: "Kuranga"},
        {display: "Navadra", value: "Navadra"},
        {display: "Harshad_Miyani", value: "Harshad_Miyani"},
        {display: "Tukda_Miyani", value: "Tukda_Miyani"},
        {display: "Raatadi", value: "Raatadi"},
        {display: "Kuchhadi", value: "Kuchhadi"},
        {display: "Porbandar", value: "Porbandar"},
        {display: "odadar", value: "odadar"},
        {display: "Navibandar", value: "Navibandar"},
        {display: "Gorsar", value: "Gorsar"},
        {display: "Madhavpur", value: "Madhavpur"},
        {display: "Mangrol", value: "Mangrol"},
        {display: "Chorwad", value: "Chorwad"},
        {display: "Adri", value: "Adri"},
        {display: "Veraval", value: "Veraval"},
        {display: "Kadwar", value: "Kadwar"},
        {display: "Vadodra", value: "Vadodra"},
        {display: "Mul_Dwarka", value: "Mul_Dwarka"},
        {display: "Nava_Bandar", value: "Nava_Bandar"},
        {display: "Simar", value: "	Simar"},
        {display: "Saiyad_Rajpara", value: "Saiyad_Rajpara"},
        {display: "Kotda", value: "Kotda"},
        {display: "Diu_Island", value: "Diu_Island"},
        {display: "Rohisa", value: "Rohisa"},
        {display: "Jafarabad", value: "Jafarabad"},
        {display: "Pipavav", value: "Pipavav"},
        {display: "Patva", value: "Patva"},
        {display: "Gadhada", value: "Gadhada"},
        {display: "Mahuva", value: "Mahuva"},
        {display: "Nikol", value: "Nikol"},
        {display: "Methla", value: "Methla"},
        {display: "Jhanjhmer", value: "Jhanjhmer"},
        {display: "Gopnath", value: "Gopnath"},
        {display: "Sartanpar", value: "Sartanpar"},
        {display: "Alang", value: "Alang"},
        {display: "Mithi_Virdi", value: "Mithi_Virdi"},
        {display: "Haathab", value: "Haathab"},
        {display: "Piram_Bet", value: "Piram_Bet"},
        {display: "Ghogha", value: "Ghogha"},
        {display: "Bhavanagar_New_Port", value: "Bhavanagar_New_Port"},
        {display: "Dungariya_Bet", value: "Dungariya_Bet"},
        {display: "Kamatalav", value: "Kamatalav"},
        {display: "Vadgam", value: "Vadgam"},
        {display: "Khambat", value: "Khambat"},
        {display: "Sarod", value: "Sarod"},
        {display: "Gangeshwar", value: "Gangeshwar"},
        {display: "Tankari_Pt", value: "Tankari_Pt"},
        {display: "Nadiyad", value: "Nadiyad"},
        {display: "Denwa", value: "Denwa"},
        {display: "Luhara_Pt", value: "Luhara_Pt"},
        {display: "Mehgam", value: "Mehgam"},
        {display: "Dhanturia", value: "Dhanturia"},
        {display: "Oil_Derrick", value: "Oil_Derrick"},
        {display: "Wansnoli", value: "Wansnoli"},
        {display: "Kanthiajal", value: "Kanthiajal"},
        {display: "Karanj", value: "Karanj"},
        {display: "Marphalia", value: "Marphalia"},
        {display: "Hazira", value: "Hazira"},
        {display: "Bhimpur", value: "Bhimpur"},
        {display: "Dipla", value: "Dipla"},
        {display: "Wasi_Borsi", value: "Wasi_Borsi"},
        {display: "Dandi", value: "Dandi"},
        {display: "Machhiwada", value: "Machhiwada"},
        {display: "Mendhar", value: "Mendhar"},
        {display: "Valsad", value: "Valsad"},
        {display: "Bhimpor", value: "Bhimpor"},
        {display: "Daman", value: "Daman"},
        {display: "Kalai", value: "Kalai"},
        {display: "Maroli", value: "Maroli"},
        {display: "Nargol", value: "Nargol"},
        {display: "Umargam", value: "Umargam"}
    ];
    var maharashtra = [
        {display: "Bordi", value: "Bordi"},
        {display: "Gholvad", value: "Gholvad"},
        {display: "Khondha_Cr", value: "Khondha_Cr"},
        {display: "Tarapur_Pt", value: "Tarapur_Pt"},
        {display: "Navapur_(Ucheli_Cr)", value: "Navapur_(Ucheli_Cr)"},
        {display: "Satpati", value: "Satpati"},
        {display: "Mahim_Cr", value: "Mahim_Cr"},
        {display: "Arnalapada", value: "Arnalapada"},
        {display: "Vasai", value: "Vasai"},
        {display: "Dongi_Point", value: "Dongi_Point"},
        {display: "Vesava", value: "Vesava"},
        {display: "Uarashi_Rf", value: "Uarashi_Rf"},
        {display: "Malabar_Port_(Mumbai)", value: "Malabar_Port_(Mumbai)"},
        {display: "Colaba_Pt.(Mumbai)", value: "Colaba_Pt.(Mumbai)"},
        {display: "Belapur", value: "Belapur"},
        {display: "Uran", value: "Uran"},
        {display: "Karanja_Uran", value: "Karanja_Uran"},
        {display: "Bhalpada", value: "Bhalpada"},
        {display: "Avas", value: "Avas"},
        {display: "Thal", value: "Thal"},
        {display: "Alibag", value: "Alibag"},
        {display: "Nagaon", value: "Nagaon"},
        {display: "Boghar", value: "Boghar"},
        {display: "Revadanda", value: "Revadanda"},
        {display: "Korlai", value: "Korlai"},
        {display: "Mazgaon", value: "Mazgaon"},
        {display: "Murud", value: "Murud"},
        {display: "Mandad", value: "Mandad"},
        {display: "Kudgaon", value: "Kudgaon"},
        {display: "Nanwell_Pt", value: "Nanwell_Pt"},
        {display: "Diveagar", value: "Diveagar"},
        {display: "Srivardhan", value: "Srivardhan"},
        {display: "Bankot", value: "Bankot"},
        {display: "Velas", value: "Velas"},
        {display: "Kelsi", value: "Kelsi"},
        {display: "Anjarle", value: "Anjarle"},
        {display: "Harne", value: "Harne"},
        {display: "Murud", value: "Murud"},
        {display: "Burondi", value: "Burondi"},
        {display: "Kolthare", value: "Kolthare"},
        {display: "Dabhol", value: "Dabhol"},
        {display: "Tolkeshwar_Pt", value: "Tolkeshwar_Pt"},
        {display: "Guhagar", value: "Guhagar"},
        {display: "Palshet", value: "Palshet"},
        {display: "Hedvi", value: "Hedvi"},
        {display: "Jaigad", value: "Jaigad"},
        {display: "Jaigarh_Head", value: "Jaigarh_Head"},
        {display: "Kharviwada", value: "Kharviwada"},
        {display: "MTDC", value: "MTDC"},
        {display: "Kalabadevi", value: "Kalabadevi"},
        {display: "Mirkarwada", value: "Mirkarwada"},
        {display: "Ratnagiri", value: "Ratnagiri"},
        {display: "Rajiwada-Kerla", value: "Rajiwada-Kerla"},
        {display: "Purnagad", value: "Purnagad"},
        {display: "Purangad", value: "Purangad"},
        {display: "Sakhri-Natye", value: "Sakhri-Natye"},
        {display: "Mavlanga", value: "Mavlanga"},
        {display: "Bokarwadi", value: "Bokarwadi"},
        {display: "Wada_Vetye", value: "Wada_Vetye"},
        {display: "Ambolgarh", value: "Ambolgarh"},
        {display: "Wagapur_Pt", value: "Wagapur_Pt"},
        {display: "Vijayadurg_Hr", value: "Vijayadurg_Hr"},
        {display: "Kalamaiwadi", value: "Kalamaiwadi"},
        {display: "Devgarh", value: "Devgarh"},
        {display: "Kunkeshwar", value: "Kunkeshwar"},
        {display: "Munge", value: "Munge"},
        {display: "Achra_Pt", value: "Achra_Pt"},
        {display: "Hadi", value: "Hadi"},
        {display: "Sarjekot", value: "Sarjekot"},
        {display: "Sindhudurg_(Malvan)", value: "Sindhudurg_(Malvan)"},
        {display: "Vengurla", value: "Vengurla"},
        {display: "Terekhol", value: "Terekhol"}
    ];
    var kerala = [
        {display: "Manjeshwara", value: "Manjeshwara"},
        {display: "Kumbla", value: "Kumbla"},
        {display: "Kasaragod", value: "Kasaragod"},
        {display: "Bekal", value: "Bekal"},
        {display: "Hosdrug", value: "Hosdrug"},
        {display: "Nileswaram", value: "Nileswaram"},
        {display: "Maniyat", value: "Maniyat"},
        {display: "Kavvayi", value: "Kavvayi"},
        {display: "Kunnariyam", value: "Kunnariyam"},
        {display: "Kotte_Kunnu", value: "Kotte_Kunnu"},
        {display: "Valapattanam", value: "Valapattanam"},
        {display: "Azhikal", value: "Azhikal"},
        {display: "Kannur", value: "Kannur"},
        {display: "Tellicherry", value: "Tellicherry"},
        {display: "Mahe", value: "Mahe"},
        {display: "Uralungal", value: "Uralungal"},
        {display: "Nalliyankara", value: "Nalliyankara"},
        {display: "Badagara", value: "Badagara"},
        {display: "Puduppanam", value: "Puduppanam"},
        {display: "Kottakkal", value: "Kottakkal"},
        {display: "Tikkoti", value: "Tikkoti"},
        {display: "Kadalur_Pt", value: "Kadalur_Pt"},
        {display: "Kollam", value: "Kollam"},
        {display: "Chemancheri", value: "Chemancheri"},
        {display: "Elattur", value: "Elattur"},
        {display: "Nadakkavu", value: "Nadakkavu"},
        {display: "Calicut", value: "Calicut"},
        {display: "Ramanattukara", value: "Ramanattukara"},
        {display: "Beypore", value: "Beypore"},
        {display: "Parappanangadi", value: "Parappanangadi"},
        {display: "Tanur_Nagaram", value: "Tanur_Nagaram"},
        {display: "Paravannangadi", value: "Paravannangadi"},
        {display: "Purattur", value: "Purattur"},
        {display: "Ponnani", value: "Ponnani"},
        {display: "Veliyangod", value: "Veliyangod"},
        {display: "Vayilattur", value: "Vayilattur"},
        {display: "Chavakkad", value: "Chavakkad"},
        {display: "Mullassheri", value: "Mullassheri"},
        {display: "Edamuttam", value: "Edamuttam"},
        {display: "Kulimuttam", value: "Kulimuttam"},
        {display: "Pullut", value: "Pullut"},
        {display: "Kodungallur", value: "Kodungallur"},
        {display: "Munambam", value: "Munambam"},
        {display: "Cherai", value: "Cherai"},
        {display: "Edvankad", value: "Edvankad"},
        {display: "Narakkal", value: "Narakkal"},
        {display: "Nayarambalam", value: "Nayarambalam"},
        {display: "Malipuram", value: "Malipuram"},
        {display: "Ernakulam", value: "Ernakulam"},
        {display: "Vypeen", value: "Vypeen"},
        {display: "Valarpadam", value: "Valarpadam"},
        {display: "Kochi", value: "Kochi"},
        {display: "Chellanum", value: "Chellanum"},
        {display: "Palithodu", value: "Palithodu"},
        {display: "Manakkodam", value: "Manakkodam"},
        {display: "Aratungal", value: "Aratungal"},
        {display: "Kottamkulangara", value: "Kottamkulangara"},
        {display: "Alleppey", value: "Alleppey"},
        {display: "Kalarkod", value: "Kalarkod"},
        {display: "Punnappira", value: "Punnappira"},
        {display: "Ambalapuzha", value: "Ambalapuzha"},
        {display: "Porakad", value: "Porakad"},
        {display: "Trikkunnapuzha", value: "Trikkunnapuzha"},
        {display: "Padiyamkara_Tekku", value: "Padiyamkara_Tekku"},
        {display: "Ramancheri_Tura", value: "Ramancheri_Tura"},
        {display: "Azhikal", value: "Azhikal"},
        {display: "Alappattu", value: "Alappattu"},
        {display: "Kovilthottam", value: "Kovilthottam"},
        {display: "Chavara", value: "Chavara"},
        {display: "Neendakara", value: "Neendakara"},
        {display: "Quilon", value: "Quilon"},
        {display: "Tanni", value: "Tanni"},
        {display: "Pozhikara", value: "Pozhikara"},
        {display: "Kappil", value: "Kappil"},
        {display: "Edaval", value: "Edaval"},
        {display: "Vettur", value: "Vettur"},
        {display: "Anjengo", value: "Anjengo"},
        {display: "Perumatura", value: "Perumatura"},
        {display: "Thumba", value: "Thumba"},
        {display: "Vell", value: "Vell"},
        {display: "Trivandrum", value: "Trivandrum"},
        {display: "Tiruvallam", value: "Tiruvallam"},
        {display: "Vilinjam", value: "Vilinjam"},
        {display: "Mariyanadu", value: "Mariyanadu"},
        {display: "Karichal", value: "Karichal"},
        {display: "Puvar", value: "Puvar"}
    ];
    var tamilnadu = [
        {display: "Marthandam_VKC", value: "Marthandam_VKC"},
        {display: "Taingapatnam", value: "Taingapatnam"},
        {display: "Kolachel", value: "Kolachel"},
        {display: "Neerody", value: "Neerody"},
        {display: "Kovalam", value: "Kovalam"},
        {display: "Muttom", value: "Muttom"},
        {display: "Kadiapattanam", value: "Kadiapattanam"},
        {display: "Rajakkamanglam", value: "Rajakkamanglam"},
        {display: "Puttantura", value: "Puttantura"},
        {display: "Keezhamanakudi", value: "Keezhamanakudi"},
        {display: "Puthur", value: "Puthur"},
        {display: "Kanniyakumari", value: "Kanniyakumari"},
        {display: "Lipuram", value: "Lipuram"},
        {display: "Chettikulam", value: "Chettikulam"},
        {display: "Kudangulam", value: "Kudangulam"},
        {display: "Kuttankuli", value: "Kuttankuli"},
        {display: "Kundal", value: "Kundal"},
        {display: "Manappad_Pt", value: "Manappad_Pt"},
        {display: "Alantalai", value: "Alantalai"},
        {display: "Virapandiyanpattinam", value: "Virapandiyanpattinam"},
        {display: "Punnaikkayal", value: "Punnaikkayal"},
        {display: "Pandyan", value: "Pandyan"},
        {display: "Tuticorin", value: "Tuticorin"},
        {display: "Pattanamarudur", value: "Pattanamarudur"},
        {display: "Veppalodai", value: "Veppalodai"},
        {display: "Vaippar", value: "Vaippar"},
        {display: "Vembar", value: "Vembar"},
        {display: "Terku_Mukkaiyur", value: "Terku_Mukkaiyur"},
        {display: "Valinokkam", value: "Valinokkam"},
        {display: "Kilakarai", value: "Kilakarai"},
        {display: "Muttupettai", value: "Muttupettai"},
        {display: "Vanagapuri", value: "Vanagapuri"},
        {display: "Seeniyappa_tharya", value: "Seeniyappa_tharya"},
        {display: "Mandapam", value: "Mandapam"},
        {display: "Pamban_kunthukal", value: "Pamban_kunthukal"},
        {display: "Dhanushkodi", value: "Dhanushkodi"},
        {display: "Olaikuda", value: "Olaikuda"},
        {display: "Verkode", value: "Verkode"},
        {display: "Rameswaram_harbour", value: "Rameswaram_harbour"},
        {display: "Viloondi", value: "Viloondi"},
        {display: "Thangachimadam", value: "Thangachimadam"},
        {display: "Pamban_lht", value: "Pamban_lht"},
        {display: "Mandapam_jetty", value: "Mandapam_jetty"},
        {display: "Attangarai", value: "Attangarai"},
        {display: "Devipattinam", value: "Devipattinam"},
        {display: "Moreppanai", value: "Moreppanai"},
        {display: "Tiruvettriyur", value: "Tiruvettriyur"},
        {display: "Tondi", value: "Tondi"},
        {display: "Sundarapandiyanpatta", value: "Sundarapandiyanpatta"},
        {display: "Gopalapatnam", value: "Gopalapatnam"},
        {display: "Kottaippattanam", value: "Kottaippattanam"},
        {display: "Manamelkudi", value: "Manamelkudi"},
        {display: "Prataparamanpattinam", value: "Prataparamanpattinam"},
        {display: "Setubavachattram", value: "Setubavachattram"},
        {display: "Atirampattinam", value: "Atirampattinam"},
        {display: "Muthupet", value: "Muthupet"},
        {display: "Point_Calimere", value: "Point_Calimere"},
        {display: "Vedaranniyam", value: "Vedaranniyam"},
        {display: "Topputturai", value: "Topputturai"},
        {display: "Akkaraipettai", value: "Akkaraipettai"},
        {display: "Kallinodu", value: "Kallinodu"},
        {display: "Vellapallam", value: "Vellapallam"},
        {display: "Vettaikaranrippu", value: "Vettaikaranrippu"},
        {display: "Kameshwaram", value: "Kameshwaram"},
        {display: "Serugur", value: "Serugur"},
        {display: "Velanganni", value: "Velanganni"},
        {display: "Nagappattinam", value: "Nagappattinam"},
        {display: "Nagore", value: "Nagore"},
        {display: "Karikal", value: "Karikal"},
        {display: "Pattinacherry", value: "Pattinacherry"},
        {display: "Tranquebar", value: "Tranquebar"},
        {display: "Chinnangudi", value: "Chinnangudi"},
        {display: "Poombuhar", value: "Poombuhar"},
        {display: "Thalampettai", value: "Thalampettai"},
        {display: "Kaverippattinam", value: "Kaverippattinam"},
        {display: "Tirumullaivasal", value: "Tirumullaivasal"},
        {display: "Mudasalodai_Village", value: "Mudasalodai_Village"},
        {display: "Parangipettai", value: "Parangipettai"},
        {display: "Samiyarpettai_Village", value: "Samiyarpettai_Village"},
        {display: "Pazhayar", value: "Pazhayar"},
        {display: "Pudukuppam", value: "Pudukuppam"},
        {display: "Panithittu", value: "Panithittu"},
        {display: "Portonovo", value: "Portonovo"},
        {display: "Pudukuppam", value: "Pudukuppam"},
        {display: "Veerampatinam", value: "Veerampatinam"},
        {display: "Samanthapettai", value: "Samanthapettai"},
        {display: "Kumarapettai", value: "Kumarapettai"},
        {display: "Periyakuppam", value: "Periyakuppam"},
        {display: "Chitharaipettai", value: "Chitharaipettai"},
        {display: "Cuddalore", value: "Cuddalore"},
        {display: "Thengaithittu", value: "Thengaithittu"},
        {display: "Murthipudukuppam", value: "Murthipudukuppam"},
        {display: "Nallavadu", value: "Nallavadu"},
        {display: "ChinnaVeerampattinam", value: "ChinnaVeerampattinam"},
        {display: "Pondicherry", value: "Pondicherry"},
        {display: "Vaithikuppam", value: "Vaithikuppam"},
        {display: "Solainagar_North", value: "Solainagar_North"},
        {display: "Pillaichavadi", value: "Pillaichavadi"},
        {display: "Ganapathichettikulam", value: "Ganapathichettikulam"},
        {display: "Malakkanam", value: "Malakkanam"},
        {display: "Cheyyur", value: "Cheyyur"},
        {display: "Sadras", value: "Sadras"},
        {display: "Mahabalipuram", value: "Mahabalipuram"},
        {display: "Covelong_(Kovalam)", value: "Covelong_(Kovalam)"},
        {display: "Thiruvanmiyur", value: "Thiruvanmiyur"},
        {display: "Cathedral_(Chennai)", value: "Cathedral_(Chennai)"},
        {display: "Chennai", value: "Chennai"},
        {display: "Royapuram", value: "Royapuram"},
        {display: "Ennur", value: "Ennur"},
        {display: "Pulicat", value: "Pulicat"},
        {display: "Coromandel", value: "Coromandel"}
    ];




    //If parent option is changed
    $("#state").change(function () {
        var parent = $(this).val(); //get option value from parent 

        switch (parent) { //using switch compare selected option and populate child
            case 'Karnataka':
                list(Karnataka);
                break;
            case 'Andhra Pradesh':
                list(Andhra);
                break;
            case 'Goa':
                list(Goa);
                break;
            case 'West Bengal':
                list(West_bengal);
                break;
            case 'Andaman Nicobar':
                list(andaman);
                break;
            case 'Lakshadweep':
                list(lakshadweep);
                break;
            case 'Odissa':
                list(odissa);
                break;
            case 'Gujarat':
                list(gujarath);
                break;
            case 'Maharashtra':
                list(maharashtra);
                break;
            case 'Kerala':
                list(kerala);
                break;

            case 'Tamil Nadu':
                list(tamilnadu);
                break;
            default:
                //default child option is blank
                $("#landingcenter").html('');
                break;
        }
    });
    //function to populate child select box
    function list(array_list)
    {
        $("#landingcenter").html(""); //reset child options
        $(array_list).each(function (i) { //populate child options 
            $("#landingcenter").append("<option value=\"" + array_list[i].value + "\">" + array_list[i].display + "</option>");
        });
    }
    /*checking on focus*/
    $('#angle').focus(function () {
        var traveled_distance = $('#traveled_distance').val();
        if (traveled_distance === '') {
            alert("please Fill the traveled distance");
            $('#traveled_distance').focus();
        }
    });
    $('#traveled_distance').change(function () {
        var landingcenter = $('#landingcenter').val();
        var traveled_distance = $('#traveled_distance').val();
        var angle = $('#angle').val();
        if (traveled_distance === '')
            alert("please Fill the traveled distance");
        if (angle == '')
            alert("please Enter The Bearing Angle");
        if (traveled_distance != '' && angle != '')
        {
            destVincenty(hashtable[landingcenter][0], hashtable[landingcenter][1], angle, traveled_distance);
        }
    });
    $('#angle').change(function () {
        var traveled_distance = $('#traveled_distance').val();
        var angle = $('#angle').val();
        var landingcenter = $('#landingcenter').val();
        if (traveled_distance != '' && traveled_distance != '')
        {
            destVincenty(hashtable[landingcenter][0], hashtable[landingcenter][1], angle, traveled_distance);
        }

    });
});

function myselection()
{
    // var latlng_known=document.getElementsByTagName("latlng_known").value;
    var latlng_known = document.forms["input_form"]["latlng_known"].value;
    if (latlng_known === "no")
    {

        $('.unknown_latlng').show();
        document.getElementById("traveled_distance").attributes["required"] = "true";
        document.getElementById("angle").attributes["required"] = "true";
    }
    else if (latlng_known === "yes")
    {
        $('.unknown_latlng').hide();
        document.getElementById("traveled_distance").required = false;
        document.getElementById("angle").required = false;
    }

}//myselection function
function lalongCalculation()
{

//var lat= document.forms["input_form"]["Slat"].value;
//var lng= document.forms["input_form"]["Slong"].value;
    var landing_center = document.forms["input_form"]["landingcenter"].value;
    var distance = document.forms["input_form"]["traveled_distance"].value;
    var angle = document.forms["input_form"]["angle"].value;
    if ($.trim($('#traveled_distance').val()) === '') {
        alert('Enter the distance traveled');
        return;
    }
    if ($.trim($('#angle').val()) === '') {
        alert('Enter angle in which u travled');
        return;
    }
    if (landing_center === "mangalore") {
        destVincenty(12.85, 74.84, angle, distance);
    }

}

function toRad(n) {
    return n * Math.PI / 180;
}
function toDeg(n) {
    return n * 180 / Math.PI;
}
function destVincenty(lat1, lon1, brng, dist) {
    dist = dist / 6371;
    brng = toRad(brng);
    var slat1 = toRad(lat1), slon1 = toRad(lon1);
    var clat2 = Math.asin(Math.sin(slat1) * Math.cos(dist) + Math.cos(slat1) * Math.sin(dist) * Math.cos(brng));
    var clon2 = slon1 + Math.atan2(Math.sin(brng) * Math.sin(dist) *
            Math.cos(slat1),
            Math.cos(dist) - Math.sin(slat1) *
            Math.sin(clat2));
    if (isNaN(clat2) || isNaN(clon2))
    {
        document.getElementById('flat').value = lat1;
        document.getElementById('flong').value = lon1;
        updateMap();
    }
    else {

        document.getElementById('latitude').value = toDeg(clat2).toFixed(3);
        document.getElementById('longitude').value = toDeg(clon2).toFixed(3);
        updateMap();
    }
}
