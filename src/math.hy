// IEEE-754 double math in pure Coil, replacing the `prelude::math` host
// natives. The algorithms are ports of FreeBSD msun / musl (sin, cos, tan,
// expm1, ln, log2, log10, atan, atan2, asin, acos, sinh, cosh, tanh), ARM
// optimized-routines (exp, as in glibc and musl) and CORE-MATH (cbrt). They work on float values only: Coil has no float
// bit casts, so exponents come from `exponent_of` and the high/low word
// tricks of the C sources are replaced by Veltkamp splits.
//
// `sqrt`, `floor` and `ceil` are exact (correctly rounded); `cbrt` is
// correctly rounded; the rest stay within 1 ulp like the C originals.

// 2^n.
const TWO24 = 16777216.0;

const TWO_M24 = 1.0 / 16777216.0;

const TWO52 = 4503599627370496.0;

const TWO54 = 18014398509481984.0;

const TWO64 = 2.0 ** 64.0;

const TWO66 = 2.0 ** 66.0;

const TWO_M27 = 2.0 ** -27.0;

const TWO_M52 = 2.0 ** -52.0;

const TWO_M53 = 2.0 ** -53.0;

const TWO_M54 = 2.0 ** -54.0;

const TWO_M75 = 2.0 ** -75.0;

const TWO_M98 = 2.0 ** -98.0;

const TWO_M120 = 2.0 ** -120.0;

const P1021 = 2.0 ** 1021.0;

const P1009 = 2.0 ** 1009.0;

const P1023 = 2.0 ** 1023.0;

// 2^-1022 * 2^53: one scalbn step into the subnormal range without double rounding.
const P969N = 2.0 ** -969.0;

const MIN_NORMAL = 2.0 ** -1022.0;

const P512 = 2.0 ** 512.0;

const P256 = 2.0 ** 256.0;

const P128 = 2.0 ** 128.0;

const P64 = 2.0 ** 64.0;

const P32 = 2.0 ** 32.0;

const P16 = 65536.0;

const N512 = 2.0 ** -512.0;

const N256 = 2.0 ** -256.0;

const N128 = 2.0 ** -128.0;

const N64 = 2.0 ** -64.0;

const N32 = 2.0 ** -32.0;

const N16 = 1.0 / 65536.0;

const N511 = 2.0 ** -511.0;

const N255 = 2.0 ** -255.0;

const N127 = 2.0 ** -127.0;

const N63 = 2.0 ** -63.0;

const N31 = 2.0 ** -31.0;

const N15 = 2.0 ** -15.0;

const N7 = 2.0 ** -7.0;

// Veltkamp splitters: `c - (c - a)` with `c = SPLIT * a` keeps the top
// 26 (SPLIT) or 21 (SPLIT21) significant bits of `a`.
const SPLIT = 134217729.0;

const SPLIT21 = 4294967297.0;

// Thresholds the C sources test on the high 32 bits of a double, as values.
const SIN_SMALL = 0.000000014901161193847656;

const PIO4_HW = 0.7853984832763672;

const COS_SMALL = 0.000000010536709282860102;

const TAN_SMALL = 0.000000007450580596923828;

const MEDIUM = 1647099.0;

const KTAN_BIG = 0.6743354797363281;

const HALF_LN2 = 0.3465735912322998;

const THREEHALF_LN2 = 1.0397205352783203;

const EXP_OVER = 709.782712893384;

const EXPM1_BIG = 38.81622314453125;

const EXPM1_TINY = 0.00000000000000005551115123125783;

const SQRT2_HW = 1.4142131805419922;

const SINH_BIG = 709.7822265625;

const COSH_SMALL = 0.6931467056274414;

const TANH_A = 0.5493063926696777;

const TANH_B = 20.000015258789063;

const TANH_C = 0.2554128170013428;

const ASIN_975 = 0.9749999046325684;

const ACOS_TINY = 0.000000000000000006938900521352129;

const K_LN2 = 1416.0996898839683;

// pi and pi/2 split into a double and the remainder.
const PI_HI = 3.141592653589793;

const PI_LO = 0.00000000000000012246467991473532;

const PIO2_HI = 1.5707963267948966;

const PIO2_LO = 0.00000000000000006123233995736766;

const PIO4 = 0.7853981633974483;

const PIO4_LO = 0.00000000000000003061616997868383;

// Argument reduction by pi/2 (__rem_pio2): pi/2 as three 33-bit pieces plus tails.
const INV_PIO2 = 0.6366197723675814;

const PIO2_1 = 1.5707963267341256;

const PIO2_1T = 0.00000000006077100506506192;

const PIO2_2 = 0.00000000006077100506303966;

const PIO2_2T = 0.0000000000000000000020222662487959506;

const PIO2_3 = 0.0000000000000000000020222662487111665;

const PIO2_3T = 0.000000000000000000000000000000084784276603689;

// pi/2 in 24-bit pieces for the Payne-Hanek reduction (__rem_pio2_large).
const PIO2_T0 = 1.570796251296997;

const PIO2_T1 = 0.00000007549789415861596;

const PIO2_T2 = 0.000000000000005390302529957765;

const PIO2_T3 = 0.0000000000000000000003282003415807913;

const PIO2_T4 = 0.00000000000000000000000000001270655753080676;

// 2/pi in 24-bit chunks, for the Payne-Hanek reduction.
const IPIO2 = readonly [
    0xA2F983, 0x6E4E44, 0x1529FC, 0x2757D1, 0xF534DD, 0xC0DB62, 0x95993C, 0x439041, 0xFE5163, 0xABDEBB,
    0xC561B7, 0x246E3A, 0x424DD2, 0xE00649, 0x2EEA09, 0xD1921C, 0xFE1DEB, 0x1CB129, 0xA73EE8, 0x8235F5,
    0x2EBB44, 0x84E99C, 0x7026B4, 0x5F7E41, 0x3991D6, 0x398353, 0x39F49C, 0x845F8B, 0xBDF928, 0x3B1FF8,
    0x97FFDE, 0x05980F, 0xEF2F11, 0x8B5A0A, 0x6D1F6D, 0x367ECF, 0x27CB09, 0xB74F46, 0x3F669E, 0x5FEA2D,
    0x7527BA, 0xC7EBE5, 0xF17B3D, 0x0739F7, 0x8A5292, 0xEA6BFB, 0x5FB11F, 0x8D5D08, 0x560330, 0x46FC7B,
    0x6BABF0, 0xCFBC20, 0x9AF436, 0x1DA9E3, 0x91615E, 0xE61B08, 0x659985, 0x5F14A0, 0x68408D, 0xFFD880,
    0x4D7327, 0x310606, 0x1556CA, 0x73A8C9, 0x60E27B, 0xC08C6B,
];

// sin on [-pi/4, pi/4] (__kernel_sin).
const SIN_S1 = -0.16666666666666632;

const SIN_S2 = 0.00833333333332249;

const SIN_S3 = -0.0001984126982985795;

const SIN_S4 = 0.0000027557313707070068;

const SIN_S5 = -0.000000025050760253406863;

const SIN_S6 = 0.000000000158969099521155;

// cos on [-pi/4, pi/4] (__kernel_cos).
const COS_C1 = 0.0416666666666666;

const COS_C2 = -0.001388888888887411;

const COS_C3 = 0.00002480158728947673;

const COS_C4 = -0.00000027557314351390663;

const COS_C5 = 0.000000002087572321298175;

const COS_C6 = -0.000000000011359647557788195;

// tan on [-pi/4, pi/4] (__kernel_tan).
const TAN_T0 = 0.3333333333333341;

const TAN_T1 = 0.13333333333320124;

const TAN_T2 = 0.05396825397622605;

const TAN_T3 = 0.021869488294859542;

const TAN_T4 = 0.0088632398235993;

const TAN_T5 = 0.0035920791075913124;

const TAN_T6 = 0.0014562094543252903;

const TAN_T7 = 0.0005880412408202641;

const TAN_T8 = 0.0002464631348184699;

const TAN_T9 = 0.00007817944429395571;

const TAN_T10 = 0.00007140724913826082;

const TAN_T11 = -0.000018558637485527546;

const TAN_T12 = 0.00002590730518636337;

// exp (ARM optimized-routines, as in glibc and musl): 2^(j/128) ~=
// EXP_SCALE[j] * (1 + EXP_TAIL[j]), x ~= k*ln2/128 + r, and a quartic in r.
const EXP_SCALE = readonly [
    1.0, 1.0054299011128027, 1.0108892860517005, 1.016378314910953, 1.0218971486541166,
    1.0274459491187637, 1.0330248790212284, 1.0386341019613787, 1.0442737824274138,
    1.0499440858006872, 1.0556451783605572, 1.061377227289262, 1.0671404006768237,
    1.0729348675259756, 1.0787607977571199, 1.0846183622133092, 1.0905077326652577,
    1.0964290818163769, 1.102382583307841, 1.1083684117236787, 1.1143867425958924,
    1.1204377524096067, 1.1265216186082418, 1.1326385195987192, 1.1387886347566916,
    1.1449721444318042, 1.1511892299529827, 1.1574400736337511, 1.1637248587775775,
    1.1700437696832502, 1.1763969916502812, 1.182784710984341, 1.189207115002721,
    1.1956643920398273, 1.202156731452703, 1.2086843236265816, 1.215247359980469,
    1.2218460329727576, 1.22848053610687, 1.2351510639369334, 1.241857812073484, 1.2486009771892048,
    1.255380757024691, 1.2621973503942507, 1.2690509571917332, 1.275941778396392,
    1.2828700160787783, 1.2898358734066657, 1.2968395546510096, 1.3038812651919358,
    1.3109612115247644, 1.318079601266064, 1.3252366431597413, 1.3324325470831615,
    1.339667524053303, 1.3469417862329458, 1.3542555469368927, 1.3616090206382248,
    1.3690024229745905, 1.3764359707545302, 1.383909881963832, 1.3914243757719262,
    1.3989796725383112, 1.4065759938190154, 1.4142135623730951, 1.4218926021691656,
    1.42961333839197, 1.4373759974489824, 1.4451808069770467, 1.4530279958490526, 1.460917794180647,
    1.4688504333369818, 1.4768261459394993, 1.4848451658727524, 1.4929077282912648,
    1.5010140696264256, 1.5091644275934228, 1.5173590411982147, 1.5255981507445384,
    1.533881997840956, 1.5422108254079407, 1.550584877685, 1.559004400237837, 1.567469639965553,
    1.5759808451078865, 1.5845382652524937, 1.593142151342267, 1.6017927556826934,
    1.6104903319492543, 1.6192351351948637, 1.6280274218573478, 1.6368674497669644,
    1.645755478153965, 1.6546917676561943, 1.6636765803267364, 1.6727101796415966,
    1.681792830507429, 1.6909247992693053, 1.7001063537185235, 1.709337763100463, 1.718619298122478,
    1.7279512309618377, 1.7373338352737062, 1.746767386199169, 1.7562521603732995,
    1.7657884359332727, 1.7753764925265212, 1.785016611318935, 1.7947090750031072,
    1.804454167806624, 1.8142521755003989, 1.8241033854070534, 1.8340080864093424,
    1.843966568958626, 1.8539791250833855, 1.864046048397789, 1.8741676341103, 1.8843441790323345,
    1.8945759815869656, 1.9048633418176741, 1.9152065613971474, 1.925605943636125,
    1.9360617934922943, 1.9465744175792332, 1.9571441241754002, 1.9677712232331759,
    1.978456026387951, 1.9891988469672663,
];

const EXP_TAIL = readonly [
    0.0, 0.00000000000000009447885451727066, -0.00000000000000001507066976926039,
    -0.00000000000000005679155082825012, 0.000000000000000049997448722726326,
    -0.00000000000000004823683599994895, 0.000000000000000007357846871247418,
    0.00000000000000005773230223741951, 0.00000000000000008189317638195515,
    0.00000000000000005326891139980878, 0.0000000000000000016665881442326747,
    -0.00000000000000001128113245461828, -0.00000000000000007402825309426177,
    -0.000000000000000003578659767309563, -0.00000000000000006170654745608695,
    0.00000000000000002919139999949279, -0.000000000000000027939114859515733,
    -0.00000000000000005399285355184285, 0.00000000000000004776959425256223,
    -0.00000000000000007927701432338473, 0.00000000000000009341710609905046,
    -0.00000000000000005534520675707472, 0.00000000000000004585670326662351,
    0.000000000000000028582430411116143, 0.00000000000000007826573258636076,
    0.00000000000000004053626906769216, 0.00000000000000002823784425951061,
    -0.00000000000000007882802262487991, 0.000000000000000032904726646008416,
    -0.0000000000000000015792094703347882, 0.00000000000000004721368121170128,
    0.000000000000000013045277096919659, 0.000000000000000033484623336251524,
    0.000000000000000038611199774925664, 0.00000000000000005527550048505249,
    -0.00000000000000003927184172445234, -0.00000000000000006346552106729483,
    -0.00000000000000008684417614865944, -0.000000000000000015456342819397733,
    -0.0000000000000000870763476495455, 0.00000000000000003750854201303127,
    -0.00000000000000006616854503526488, -0.000000000000000005346099009198751,
    -0.00000000000000002443726321015018, 0.0000000000000000021023049675215714,
    0.00000000000000007771067937501065, 0.000000000000000013357510088834541,
    0.00000000000000006938291696959204, 0.000000000000000019572585293112036,
    0.00000000000000006632256961675804, -0.00000000000000005478069123926778,
    -0.00000000000000004140839310392624, -0.000000000000000021571477251208752,
    -0.000000000000000038287766552120535, 0.00000000000000006663804589232195,
    0.000000000000000023936187400285282, 0.0000000000000000568648095791174,
    0.0000000000000000011264523354521684, 0.00000000000000007007875046906994,
    -0.000000000000000050119214278381254, -0.000000000000000048923067513522756,
    -0.000000000000000035260089953269434, -0.00000000000000006872303720902018,
    0.000000000000000005001446664133532, -0.00000000000000006835808657661922,
    -0.000000000000000011307344092910212, -0.000000000000000008416011634717156,
    -0.000000000000000029247977035436566, -0.00000000000000002092304381843353,
    -0.000000000000000039778645875427124, -0.00000000000000003833464968654295,
    0.00000000000000005763611164480894, -0.000000000000000023591094770850053,
    0.00000000000000007260074661098575, 0.00000000000000000950689710108796,
    -0.00000000000000004272956133839906, -0.00000000000000006735219232374683,
    -0.000000000000000028396044410430936, -0.00000000000000007226635472101257,
    0.00000000000000005786121003395918, 0.000000000000000051548301170786783,
    -0.000000000000000009416257568878152, 0.000000000000000024253985766689806,
    -0.00000000000000006604314051707707, -0.000000000000000006432131775424189,
    -0.000000000000000012204007601863921, -0.00000000000000006336161863401293,
    -0.000000000000000037800879246373815, 0.000000000000000015341410053603723,
    0.000000000000000012932855580427452, -0.00000000000000004123367330661149,
    0.00000000000000004703083974463456, -0.00000000000000006152602891550265,
    0.00000000000000005827849326195279, 0.00000000000000003540948262646183,
    -0.000000000000000032741571320938764, 0.00000000000000004875160526227062,
    -0.00000000000000005718569790077838, -0.000000000000000004719539664590972,
    -0.00000000000000005773451958805706, -0.000000000000000010772487078934056,
    -0.00000000000000006221808618533911, 0.00000000000000001821405440362259,
    -0.00000000000000006155536546227639, 0.00000000000000001685487290628973,
    0.000000000000000053581249177694816, 0.00000000000000003621615935336894,
    0.000000000000000008588379527574144, 0.0000000000000000101562190116415,
    -0.00000000000000002869134889187244, -0.00000000000000005495118966122005,
    -0.0000000000000000556965572431627, 0.00000000000000001790126907604513,
    -0.000000000000000032211766346200164, 0.00000000000000005265370768556274,
    0.000000000000000035089866402403033, -0.00000000000000003266924100901318,
    -0.000000000000000043657593008079375, 0.000000000000000017963932659833022,
    0.000000000000000034300925275214166, -0.00000000000000005545065618639427,
    -0.00000000000000005149009745457733, 0.00000000000000005336805878514151,
    0.00000000000000003498978661192973, 0.000000000000000045784915277060095,
    -0.00000000000000005241934575393899, 0.000000000000000020414278897578303,
    0.000000000000000004124842848606488,
];

const EXP_INVLN2N = 184.6649652337873;

const EXP_NEGLN2HIN = -0.005415212348111709;

const EXP_NEGLN2LON = -0.000000000000012864023111638346;

const EXP_C2 = 0.49999999999996786;

const EXP_C3 = 0.16666666666665886;

const EXP_C4 = 0.0416666808410674;

const EXP_C5 = 0.008333335853059549;

// expm1 (fdlibm).
const LN2_HI = 0.6931471803691238;

const LN2_LO = 0.00000000019082149292705877;

const INVLN2 = 1.4426950408889634;

const EXPM1_Q1 = -0.03333333333333313;

const EXPM1_Q2 = 0.0015873015872548146;

const EXPM1_Q3 = -0.0000793650757867488;

const EXPM1_Q4 = 0.000004008217827329362;

const EXPM1_Q5 = -0.00000020109921818362437;

// ln, log2 and log10.
const LOG_LG1 = 0.6666666666666735;

const LOG_LG2 = 0.3999999999940942;

const LOG_LG3 = 0.2857142874366239;

const LOG_LG4 = 0.22222198432149784;

const LOG_LG5 = 0.1818357216161805;

const LOG_LG6 = 0.15313837699209373;

const LOG_LG7 = 0.14798198605116586;

const IVLN2HI = 1.4426950407214463;

const IVLN2LO = 0.00000000016751713164886512;

const IVLN10HI = 0.4342944818781689;

const IVLN10LO = 0.000000000025082946711645275;

const LOG10_2HI = 0.30102999566361177;

const LOG10_2LO = 0.0000000000003694239077158931;

// atan.
const ATANHI0 = 0.4636476090008061;

const ATANHI1 = 0.7853981633974483;

const ATANHI2 = 0.982793723247329;

const ATANHI3 = 1.5707963267948966;

const ATANLO0 = 0.000000000000000022698777452961687;

const ATANLO1 = 0.00000000000000003061616997868383;

const ATANLO2 = 0.000000000000000013903311031230998;

const ATANLO3 = 0.00000000000000006123233995736766;

const ATAN_AT0 = 0.3333333333333293;

const ATAN_AT1 = -0.19999999999876483;

const ATAN_AT2 = 0.14285714272503466;

const ATAN_AT3 = -0.11111110405462356;

const ATAN_AT4 = 0.09090887133436507;

const ATAN_AT5 = -0.0769187620504483;

const ATAN_AT6 = 0.06661073137387531;

const ATAN_AT7 = -0.058335701337905735;

const ATAN_AT8 = 0.049768779946159324;

const ATAN_AT9 = -0.036531572744216916;

const ATAN_AT10 = 0.016285820115365782;

// asin and acos.
const ASIN_PS0 = 0.16666666666666666;

const ASIN_PS1 = -0.3255658186224009;

const ASIN_PS2 = 0.20121253213486293;

const ASIN_PS3 = -0.04005553450067941;

const ASIN_PS4 = 0.0007915349942898145;

const ASIN_PS5 = 0.00003479331075960212;

const ASIN_QS1 = -2.403394911734414;

const ASIN_QS2 = 2.0209457602335057;

const ASIN_QS3 = -0.6882839716054533;

const ASIN_QS4 = 0.07703815055590194;

// cbrt (CORE-MATH): 2^(1/3), 2^(2/3), a cubic for z^(1/3) on [1, 2], and two
// inputs whose rounding the iteration cannot settle.
const CBRT2 = 1.2599210498948732;

const CBRT4 = 1.5874010519681996;

const CB_C0 = 0.5528234184016472;

const CB_C1 = 0.5871142918266982;

const CB_C2 = -0.16296967194987905;

const CB_C3 = 0.02310496411078147;

const CB_U0 = 0.3333333333333333;

const CB_U1 = 0.2222222222222222;

const CB_HARD1 = 3.2146036897957497;

const CB_HARD1_R = 1.4758508835342132;

const CB_HARD2 = 6.531417795099968;

const CB_HARD2_R = 1.86925759992312;

// `|x|`; both zeros give `0.0` and NaN stays NaN.
fn fabs(float x) -> float {
    if x <= 0.0 {
        return 0.0 - x;
    }
    return x;
}

// `true` when the sign bit of `x` is set, `-0.0` included.
fn sign_bit(float x) -> bool {
    return x < 0.0 || (x == 0.0 && 1.0 / x < 0.0);
}

// The exponent `k` with `2^k <= x < 2^(k+1)`, for a positive normal finite `x`.
fn exponent_of(float x) -> int {
    let k = 0;
    if x >= 1.0 {
        if x >= P512 {
            x = x * N512;
            k = k + 512;
        }
        if x >= P256 {
            x = x * N256;
            k = k + 256;
        }
        if x >= P128 {
            x = x * N128;
            k = k + 128;
        }
        if x >= P64 {
            x = x * N64;
            k = k + 64;
        }
        if x >= P32 {
            x = x * N32;
            k = k + 32;
        }
        if x >= P16 {
            x = x * N16;
            k = k + 16;
        }
        if x >= 256.0 {
            x = x * 0.00390625;
            k = k + 8;
        }
        if x >= 16.0 {
            x = x * 0.0625;
            k = k + 4;
        }
        if x >= 4.0 {
            x = x * 0.25;
            k = k + 2;
        }
        if x >= 2.0 {
            k = k + 1;
        }
        return k;
    }
    if x < N511 {
        x = x * P512;
        k = k - 512;
    }
    if x < N255 {
        x = x * P256;
        k = k - 256;
    }
    if x < N127 {
        x = x * P128;
        k = k - 128;
    }
    if x < N63 {
        x = x * P64;
        k = k - 64;
    }
    if x < N31 {
        x = x * P32;
        k = k - 32;
    }
    if x < N15 {
        x = x * P16;
        k = k - 16;
    }
    if x < N7 {
        x = x * 256.0;
        k = k - 8;
    }
    if x < 0.125 {
        x = x * 16.0;
        k = k - 4;
    }
    if x < 0.5 {
        x = x * 4.0;
        k = k - 2;
    }
    if x < 1.0 {
        k = k - 1;
    }
    return k;
}

// 2^n, exact for `-1022 <= n <= 1023`.
fn pow2(int n) -> float {
    return 2.0 ** (n as float);
}

// `x * 2^n` with a single rounding (musl scalbn).
fn scalbn(float x, int n) -> float {
    let y = x;
    if n > 1023 {
        y = y * P1023;
        n = n - 1023;
        if n > 1023 {
            y = y * P1023;
            n = n - 1023;
            if n > 1023 {
                n = 1023;
            }
        }
    } else if n < -1022 {
        y = y * P969N;
        n = n + 969;
        if n < -1022 {
            y = y * P969N;
            n = n + 969;
            if n < -1022 {
                n = -1022;
            }
        }
    }
    return y * pow2(n);
}

// The top 26 significant bits of `a` (Veltkamp split).
fn split_hi(float a) -> float {
    let c = SPLIT * a;
    return c - (c - a);
}

// The rounding error `a * b - p` of `p = a * b`, exactly (Dekker's product).
fn mul_err(float a, float b, float p) -> float {
    let ca = SPLIT * a;
    let ah = ca - (ca - a);
    let al = a - ah;
    let cb = SPLIT * b;
    let bh = cb - (cb - b);
    let bl = b - bh;
    return ((ah * bh - p) + ah * bl + al * bh) + al * bl;
}

/// Returns the largest whole number not greater than `x`.
///
/// `-0.0`, infinities and NaN come back unchanged.
/// # Examples
///
/// ```
/// use math::{floor};
/// # use tests::assert;
/// assert!(floor(2.7) == 2.0);
/// assert!(floor(-2.1) == -3.0);
/// assert!(floor(5.0) == 5.0);
/// ```
fn floor(float x) -> float {
    if !(fabs(x) < TWO52) || x == 0.0 {
        return x;
    }
    let t = (x as int) as float;
    if t > x {
        return t - 1.0;
    }
    return t;
}

/// Returns the smallest whole number not less than `x`.
///
/// A negative `x` above `-1.0` gives `-0.0`; infinities and NaN come back unchanged.
/// # Examples
///
/// ```
/// use math::{ceil};
/// # use tests::assert;
/// assert!(ceil(2.1) == 3.0);
/// assert!(ceil(-2.7) == -2.0);
/// ```
fn ceil(float x) -> float {
    if !(fabs(x) < TWO52) || x == 0.0 {
        return x;
    }
    let t = (x as int) as float;
    if t < x {
        return t + 1.0;
    }
    if t == 0.0 && x < 0.0 {
        return -0.0;
    }
    return t;
}

/// Returns the square root of `x`, correctly rounded.
///
/// Negative `x` gives NaN; `-0.0` gives `-0.0`.
/// # Examples
///
/// ```
/// use math::{sqrt};
/// # use tests::assert;
/// assert!(sqrt(9.0) == 3.0);
/// assert!(sqrt(2.0) == 1.4142135623730951);
/// assert!(sqrt(-1.0) != sqrt(-1.0));
/// ```
fn sqrt(float x) -> float {
    if x <= 0.0 {
        if x == 0.0 {
            return x;
        }
        return (x - x) / (x - x);
    }
    if !(x - x == 0.0) {
        return x;
    }
    let v = x;
    let e = 0;
    if v < MIN_NORMAL {
        v = v * TWO54;
        e = -54;
    }
    let k = exponent_of(v);
    if (k & 1) != 0 {
        k = k - 1;
    }
    // sqrt(x) = sqrt(m) * 2^((k + e) / 2) with m in [1, 4).
    let m = v * pow2(0 - k);
    let y = 0.0;
    if m < 2.0 {
        y = 0.41421356 * m + 0.594673;
    } else {
        y = 0.29289322 * m + 0.840995;
    }
    y = 0.5 * (y + m / y);
    y = 0.5 * (y + m / y);
    y = 0.5 * (y + m / y);
    // y is within an ulp of sqrt(m); settle the rounding in integers. With
    // Y = y * 2^52 and N = m * 2^104, Y is the nearest integer to sqrt(N)
    // exactly when -Y <= Y^2 - N < Y.
    let big_y = (y * TWO52) as int;
    let mm = (m * TWO52) as int;
    while true {
        let a = big_y >> 26;
        let b = big_y & 67108863;
        let ab2 = 2 * a * b;
        let hi = a * a - mm + (ab2 >> 26);
        let t = hi * 4503599627370496 + (ab2 & 67108863) * 67108864 + b * b;
        if t >= big_y {
            big_y = big_y - 1;
        } else if t < 0 - big_y {
            big_y = big_y + 1;
        } else {
            break;
        }
    }
    return (big_y as float) * pow2(k / 2 + e / 2 - 52);
}

/// Returns the cube root of `x`, correctly rounded; negative `x` gives a negative root.
/// # Examples
///
/// ```
/// use math::{cbrt};
/// # use tests::assert;
/// assert!(cbrt(27.0) == 3.0);
/// assert!(cbrt(-8.0) == -2.0);
/// ```
fn cbrt(float x) -> float {
    if x == 0.0 || !(x - x == 0.0) {
        return x + x;
    }
    let ax = fabs(x);
    let e = 0;
    if ax < MIN_NORMAL {
        ax = ax * TWO54;
        e = -54;
    }
    let k = exponent_of(ax);
    let z = ax * pow2(0 - k);
    // |x| = z * 2^(3q + it) with z in [1, 2) and it in 0..=2; zz = z * 2^it.
    let total = k + e;
    let q = total / 3;
    let it = total - 3 * q;
    if it < 0 {
        it = it + 3;
        q = q - 1;
    }
    let zz = z;
    let isc = 1.0;
    let rsc = 1.0;
    if it == 1 {
        zz = z * 2.0;
        isc = CBRT2;
        rsc = 0.5;
    } else if it == 2 {
        zz = z * 4.0;
        isc = CBRT4;
        rsc = 0.25;
    }
    let r = 1.0 / z;
    let rr = r * rsc;
    let z2 = z * z;
    let c0 = CB_C0 + z * CB_C1;
    let c2 = CB_C2 + z * CB_C3;
    let y = c0 + z2 * c2;
    let y2 = y * y;
    let h = y2 * (y * r) - 1.0;
    y = y - (h * y) * (CB_U0 - CB_U1 * h);
    y = y * isc;
    // One Newton step on y^3 = zz with y^3 in double-double.
    y2 = y * y;
    let y2l = mul_err(y, y, y2);
    let y3 = y2 * y;
    let y3l = mul_err(y, y2, y3) + y * y2l;
    h = ((y3 - zz) + y3l) * rr;
    let dy = h * (y * CB_U0);
    let y1 = y - dy;
    dy = (y - y1) - dy;
    let ady = fabs(dy);
    let ady0 = fabs(ady - TWO_M53);
    let ady1 = fabs(ady - (TWO_M52 + TWO_M53));
    if ady0 < TWO_M75 || ady1 < TWO_M75 {
        y2 = y1 * y1;
        y2l = mul_err(y1, y1, y2);
        y3 = y2 * y1;
        y3l = mul_err(y1, y2, y3) + y1 * y2l;
        h = ((y3 - zz) + y3l) * rr;
        dy = h * (y1 * CB_U0);
        y = y1 - dy;
        dy = (y1 - y) - dy;
        y1 = y;
        ady = fabs(dy);
        ady0 = fabs(ady - TWO_M53);
        ady1 = fabs(ady - (TWO_M52 + TWO_M53));
        if ady0 < TWO_M98 || ady1 < TWO_M98 {
            if zz == CB_HARD1 {
                y1 = CB_HARD1_R;
            }
            if zz == CB_HARD2 {
                y1 = CB_HARD2_R;
            }
        }
    }
    let root = y1 * pow2(q);
    if x < 0.0 {
        return -root;
    }
    return root;
}

/// Returns e raised to the power `x`.
///
/// Overflows to infinity above about `709.78` and underflows to `0.0` below about `-745.13`.
/// # Examples
///
/// ```
/// use math::{exp};
/// use num::{E};
/// # use tests::assert;
/// assert!(exp(0.0) == 1.0);
/// assert!(exp(1.0) == E);
/// ```
fn exp(float x) -> float {
    if x != x {
        return x;
    }
    let ax = fabs(x);
    let big = !(ax < 512.0);
    if big {
        if ax >= 1024.0 {
            if x < 0.0 {
                return 0.0;
            }
            return x * P1023;
        }
    } else if ax < TWO_M54 {
        return 1.0 + x;
    }
    // x = (k / 128) * ln2 + r with |r| <= ln2 / 256, k = 128 * e + j.
    let z = EXP_INVLN2N * x;
    let k = 0;
    if z < 0.0 {
        k = (z - 0.5) as int;
    } else {
        k = (z + 0.5) as int;
    }
    let kd = k as float;
    let r = x + kd * EXP_NEGLN2HIN + kd * EXP_NEGLN2LON;
    let j = k & 127;
    let e = k >> 7;
    let r2 = r * r;
    let tmp = EXP_TAIL[j] + r + r2 * (EXP_C2 + r * EXP_C3) + r2 * r2 * (EXP_C4 + r * EXP_C5);
    if !big {
        let scale = EXP_SCALE[j] * pow2(e);
        return scale + scale * tmp;
    }
    if k > 0 {
        // 2^e may overflow on its own; scale in two steps.
        let scale = EXP_SCALE[j] * pow2(e - 1009);
        return P1009 * (scale + scale * tmp);
    }
    // The result may be subnormal: round once, at the final scaling.
    let scale = EXP_SCALE[j] * pow2(e + 1022);
    let y = scale + scale * tmp;
    if y < 1.0 {
        let lo = scale - y + scale * tmp;
        let hi = 1.0 + y;
        lo = 1.0 - hi + y + lo;
        y = (hi + lo) - 1.0;
        if y == 0.0 {
            y = 0.0;
        }
    }
    return MIN_NORMAL * y;
}

// e^x - 1, accurate for small `x` too (musl expm1).
fn expm1(float x) -> float {
    if x != x {
        return x;
    }
    let ax = fabs(x);
    let neg = x < 0.0;
    if ax >= EXPM1_BIG {
        if neg {
            return -1.0;
        }
        if x > EXP_OVER {
            return x * P1023;
        }
    }
    let k = 0;
    let c = 0.0;
    if ax >= HALF_LN2 {
        let hi = 0.0;
        let lo = 0.0;
        if ax < THREEHALF_LN2 {
            if neg {
                hi = x + LN2_HI;
                lo = -LN2_LO;
                k = -1;
            } else {
                hi = x - LN2_HI;
                lo = LN2_LO;
                k = 1;
            }
        } else {
            if neg {
                k = (INVLN2 * x - 0.5) as int;
            } else {
                k = (INVLN2 * x + 0.5) as int;
            }
            let t = k as float;
            hi = x - t * LN2_HI;
            lo = t * LN2_LO;
        }
        x = hi - lo;
        c = (hi - x) - lo;
    } else if ax < EXPM1_TINY {
        return x;
    }
    let hfx = 0.5 * x;
    let hxs = x * hfx;
    let r1 = 1.0 + hxs * (EXPM1_Q1 +
                          hxs * (EXPM1_Q2 + hxs * (EXPM1_Q3 + hxs * (EXPM1_Q4 + hxs * EXPM1_Q5))));
    let t = 3.0 - r1 * hfx;
    let e = hxs * ((r1 - t) / (6.0 - x * t));
    if k == 0 {
        return x - (x * e - hxs);
    }
    e = x * (e - c) - c;
    e = e - hxs;
    if k == -1 {
        return 0.5 * (x - e) - 0.5;
    }
    if k == 1 {
        if x < -0.25 {
            return -2.0 * (e - (x + 0.5));
        }
        return 1.0 + 2.0 * (x - e);
    }
    if k < 0 || k > 56 {
        let y = x - e + 1.0;
        if k == 1024 {
            y = y * 2.0 * P1023;
        } else {
            y = y * pow2(k);
        }
        return y - 1.0;
    }
    let uf = pow2(0 - k);
    if k < 20 {
        return (x - e + (1.0 - uf)) * pow2(k);
    }
    return (x - (e + uf) + 1.0) * pow2(k);
}

// exp(x) for x near the overflow threshold: exp(x - k*ln2) * 2^k, k = 2043.
fn expo2(float x) -> float {
    return exp(x - K_LN2) * P1021 * P1021;
}

// Splits a positive finite `x` into `(k, m)` with `x = m * 2^k` and
// `m` in `[sqrt(2)/2, sqrt(2))`, the range the log kernels expect.
fn log_reduce(float x) -> (int, float) {
    let k = 0;
    if x < MIN_NORMAL {
        x = x * TWO54;
        k = -54;
    }
    let e = exponent_of(x);
    let m = x * pow2(0 - e);
    k = k + e;
    if m >= SQRT2_HW {
        m = m * 0.5;
        k = k + 1;
    }
    return (k, m);
}

// `s * (f^2/2 + R(s^2))` with `s = f / (2 + f)`: the part of ln(1 + f)
// beyond `f - f^2/2` (FreeBSD k_log1p).
fn k_log1p(float f) -> float {
    let hfsq = 0.5 * f * f;
    let s = f / (2.0 + f);
    let z = s * s;
    let w = z * z;
    let t1 = w * (LOG_LG2 + w * (LOG_LG4 + w * LOG_LG6));
    let t2 = z * (LOG_LG1 + w * (LOG_LG3 + w * (LOG_LG5 + w * LOG_LG7)));
    return s * (hfsq + t2 + t1);
}

/// Returns the natural logarithm of `x`.
///
/// `0.0` gives negative infinity and a negative `x` gives NaN.
/// # Examples
///
/// ```
/// use math::{ln};
/// # use tests::assert;
/// assert!(ln(1.0) == 0.0);
/// assert!(ln(2.718281828459045) == 1.0);
/// ```
fn ln(float x) -> float {
    if x != x {
        return x;
    }
    if x <= 0.0 {
        if x == 0.0 {
            return -1.0 / (x * x);
        }
        return (x - x) / 0.0;
    }
    if !(x - x == 0.0) {
        return x;
    }
    if x == 1.0 {
        return 0.0;
    }
    let (k, m) = log_reduce(x);
    let f = m - 1.0;
    let hfsq = 0.5 * f * f;
    let dk = k as float;
    return k_log1p(f) + dk * LN2_LO - hfsq + f + dk * LN2_HI;
}

/// Returns the base-2 logarithm of `x`; exact powers of two give whole numbers.
/// # Examples
///
/// ```
/// use math::{log2};
/// # use tests::assert;
/// assert!(log2(8.0) == 3.0);
/// assert!(log2(0.5) == -1.0);
/// ```
fn log2(float x) -> float {
    if x != x {
        return x;
    }
    if x <= 0.0 {
        if x == 0.0 {
            return -1.0 / (x * x);
        }
        return (x - x) / 0.0;
    }
    if !(x - x == 0.0) {
        return x;
    }
    if x == 1.0 {
        return 0.0;
    }
    let (k, m) = log_reduce(x);
    let f = m - 1.0;
    let hfsq = 0.5 * f * f;
    let r = k_log1p(f);
    // hi + lo = f - hfsq + r ~ ln(1 + f), with hi short enough that hi * IVLN2HI is exact.
    let c = SPLIT21 * (f - hfsq);
    let hi = c - (c - (f - hfsq));
    let lo = f - hi - hfsq + r;
    let val_hi = hi * IVLN2HI;
    let val_lo = (lo + hi) * IVLN2LO + lo * IVLN2HI;
    let y = k as float;
    let w = y + val_hi;
    val_lo = val_lo + ((y - w) + val_hi);
    return val_lo + w;
}

/// Returns the base-10 logarithm of `x`.
/// # Examples
///
/// ```
/// use math::{log10};
/// # use tests::assert;
/// assert!(log10(1000.0) == 3.0);
/// assert!(log10(0.01) == -2.0);
/// ```
fn log10(float x) -> float {
    if x != x {
        return x;
    }
    if x <= 0.0 {
        if x == 0.0 {
            return -1.0 / (x * x);
        }
        return (x - x) / 0.0;
    }
    if !(x - x == 0.0) {
        return x;
    }
    if x == 1.0 {
        return 0.0;
    }
    let (k, m) = log_reduce(x);
    let f = m - 1.0;
    let hfsq = 0.5 * f * f;
    let r = k_log1p(f);
    let c = SPLIT21 * (f - hfsq);
    let hi = c - (c - (f - hfsq));
    let lo = f - hi - hfsq + r;
    let val_hi = hi * IVLN10HI;
    let dk = k as float;
    let y = dk * LOG10_2HI;
    let val_lo = dk * LOG10_2LO + (lo + hi) * IVLN10LO + lo * IVLN10HI;
    let w = y + val_hi;
    val_lo = val_lo + ((y - w) + val_hi);
    return val_lo + w;
}

// Reduces `x` to `n * pi/2 + (y0 + y1)` with `|y0 + y1| <= pi/4`; returns
// `(n, y0, y1)` (musl __rem_pio2). `x` must be finite.
fn rem_pio2(float x) -> (int, float, float) {
    let ax = fabs(x);
    if ax < MEDIUM {
        // n = round(x * 2/pi); n * PIO2_1 and n * PIO2_2 / PIO2_3 are exact,
        // so three rounds of subtraction leave 151 bits of pi/2.
        let t = x * INV_PIO2;
        let n = 0;
        if t < 0.0 {
            n = (t - 0.5) as int;
        } else {
            n = (t + 0.5) as int;
        }
        let fnn = n as float;
        let r = x - fnn * PIO2_1;
        let w = fnn * PIO2_1T;
        let t1 = r;
        w = fnn * PIO2_2;
        r = t1 - w;
        w = fnn * PIO2_2T - ((t1 - r) - w);
        let t2 = r;
        w = fnn * PIO2_3;
        r = t2 - w;
        w = fnn * PIO2_3T - ((t2 - r) - w);
        let y0 = r - w;
        let y1 = (r - y0) - w;
        return (n, y0, y1);
    }
    // |x| = (tx0 + tx1 * 2^-24 + tx2 * 2^-48) * 2^e0 with 24-bit whole pieces.
    let e0 = exponent_of(ax) - 23;
    let z = ax * pow2(0 - e0);
    let tx0 = (z as int) as float;
    z = (z - tx0) * TWO24;
    let tx1 = (z as int) as float;
    z = (z - tx1) * TWO24;
    let tx2 = z;
    let nx = 3;
    if tx2 == 0.0 {
        nx = 2;
        if tx1 == 0.0 {
            nx = 1;
        }
    }
    // The kernel's scratch buffers live here: as locals of rem_pio2_large they
    // would be scalar-replaced, which miscompiles its indexed loops.
    let xs: Vec<float> = Vec::new();
    xs.push(tx0);
    if nx > 1 {
        xs.push(tx1);
    }
    if nx > 2 {
        xs.push(tx2);
    }
    let f: Vec<float> = Vec::new();
    let q: Vec<float> = Vec::new();
    let fq: Vec<float> = Vec::new();
    let iq: Vec<int> = Vec::new();
    while iq.len() < 20 {
        f.push(0.0);
        q.push(0.0);
        fq.push(0.0);
        iq.push(0);
    }
    let (n, y0, y1) = rem_pio2_large(xs, e0, f, q, fq, iq);
    if x < 0.0 {
        return (0 - n, -y0, -y1);
    }
    return (n, y0, y1);
}

// Piece `k` of pi/2 in 24-bit pieces, for the Payne-Hanek reduction.
fn pio2_piece(int k) -> float {
    if k == 0 {
        return PIO2_T0;
    }
    if k == 1 {
        return PIO2_T1;
    }
    if k == 2 {
        return PIO2_T2;
    }
    if k == 3 {
        return PIO2_T3;
    }
    return PIO2_T4;
}

// Payne-Hanek reduction of `xs * 2^e0` (24-bit whole pieces, most
// significant first) by pi/2 using the bits of 2/pi (FreeBSD
// __kernel_rem_pio2, double precision, prec = 1). `f`, `q`, `fq` and `iq`
// are zeroed scratch buffers of 20 entries. Returns `(n mod 8, y0, y1)`.
fn rem_pio2_large(
    Vec<float> xs,
    int e0,
    Vec<float> f,
    Vec<float> q,
    Vec<float> fq,
    Vec<int> iq,
) -> (int, float, float) {
    let jk = 4;
    let jp = 4;
    let jx = xs.len() - 1;
    let jv = (e0 - 3) / 24;
    if jv < 0 {
        jv = 0;
    }
    let q0 = e0 - 24 * (jv + 1);
    // f[0..=jx+jk] = ipio2[jv-jx..=jv+jk], zero below the table.
    let j = jv - jx;
    let i = 0;
    while i <= jx + jk {
        if j < 0 {
            f[i] = 0.0;
        } else {
            f[i] = IPIO2[j] as float;
        }
        j = j + 1;
        i = i + 1;
    }
    i = 0;
    while i <= jk {
        let fw = 0.0;
        let jj = 0;
        while jj <= jx {
            fw = fw + xs[jj] * f[jx + i - jj];
            jj = jj + 1;
        }
        q[i] = fw;
        i = i + 1;
    }
    let jz = jk;
    let z = 0.0;
    let n = 0;
    let ih = 0;
    while true {
        // Distill q[] into 24-bit iq[], lowest chunk first.
        i = 0;
        z = q[jz];
        let jj = jz;
        while jj > 0 {
            let fw = ((TWO_M24 * z) as int) as float;
            iq[i] = (z - TWO24 * fw) as int;
            z = q[jj - 1] + fw;
            i = i + 1;
            jj = jj - 1;
        }
        // n = integer part of the product mod 8, z = its fraction.
        z = scalbn(z, q0);
        z = z - 8.0 * floor(z * 0.125);
        n = z as int;
        z = z - (n as float);
        ih = 0;
        if q0 > 0 {
            let top = iq[jz - 1] >> (24 - q0);
            n = n + top;
            iq[jz - 1] = iq[jz - 1] - (top << (24 - q0));
            ih = iq[jz - 1] >> (23 - q0);
        } else if q0 == 0 {
            ih = iq[jz - 1] >> 23;
        } else if z >= 0.5 {
            ih = 2;
        }
        if ih > 0 {
            // The fraction is above 1/2: take 1 - fraction and bump n.
            n = n + 1;
            let carry = 0;
            i = 0;
            while i < jz {
                let v = iq[i];
                if carry == 0 {
                    if v != 0 {
                        carry = 1;
                        iq[i] = 16777216 - v;
                    }
                } else {
                    iq[i] = 16777215 - v;
                }
                i = i + 1;
            }
            if q0 == 1 {
                iq[jz - 1] = iq[jz - 1] & 8388607;
            } else if q0 == 2 {
                iq[jz - 1] = iq[jz - 1] & 4194303;
            }
            if ih == 2 {
                z = 1.0 - z;
                if carry != 0 {
                    z = z - scalbn(1.0, q0);
                }
            }
        }
        if z == 0.0 {
            // Every chunk cancelled: pull more bits of 2/pi and redo.
            let acc = 0;
            i = jz - 1;
            while i >= jk {
                acc = acc | iq[i];
                i = i - 1;
            }
            if acc == 0 {
                let k = 1;
                while iq[jk - k] == 0 {
                    k = k + 1;
                }
                i = jz + 1;
                while i <= jz + k {
                    f[jx + i] = IPIO2[jv + i] as float;
                    let fw = 0.0;
                    jj = 0;
                    while jj <= jx {
                        fw = fw + xs[jj] * f[jx + i - jj];
                        jj = jj + 1;
                    }
                    q[i] = fw;
                    i = i + 1;
                }
                jz = jz + k;
                continue;
            }
        }
        break;
    }
    // Chop off zero chunks, or split the leftover z into 24-bit chunks.
    if z == 0.0 {
        jz = jz - 1;
        q0 = q0 - 24;
        while iq[jz] == 0 {
            jz = jz - 1;
            q0 = q0 - 24;
        }
    } else {
        z = scalbn(z, 0 - q0);
        if z >= TWO24 {
            let fw = ((TWO_M24 * z) as int) as float;
            iq[jz] = (z - TWO24 * fw) as int;
            jz = jz + 1;
            q0 = q0 + 24;
            iq[jz] = fw as int;
        } else {
            iq[jz] = z as int;
        }
    }
    // Chunks back to floats, then times pi/2.
    let fw = scalbn(1.0, q0);
    i = jz;
    while i >= 0 {
        q[i] = fw * (iq[i] as float);
        fw = fw * TWO_M24;
        i = i - 1;
    }
    i = jz;
    while i >= 0 {
        fw = 0.0;
        let k = 0;
        while k <= jp && k <= jz - i {
            fw = fw + pio2_piece(k) * q[i + k];
            k = k + 1;
        }
        fq[jz - i] = fw;
        i = i - 1;
    }
    fw = 0.0;
    i = jz;
    while i >= 0 {
        fw = fw + fq[i];
        i = i - 1;
    }
    let y0 = fw;
    if ih != 0 {
        y0 = -fw;
    }
    fw = fq[0] - fw;
    i = 1;
    while i <= jz {
        fw = fw + fq[i];
        i = i + 1;
    }
    let y1 = fw;
    if ih != 0 {
        y1 = -fw;
    }
    return (n & 7, y0, y1);
}

// sin(x + y) for |x + y| <= pi/4, y the tail of x; `iy == 0` means y is 0.
fn k_sin(float x, float y, int iy) -> float {
    let z = x * x;
    let w = z * z;
    let r = SIN_S2 + z * (SIN_S3 + z * SIN_S4) + z * w * (SIN_S5 + z * SIN_S6);
    let v = z * x;
    if iy == 0 {
        return x + v * (SIN_S1 + z * r);
    }
    return x - ((z * (0.5 * y - v * r) - y) - v * SIN_S1);
}

// cos(x + y) for |x + y| <= pi/4, y the tail of x.
fn k_cos(float x, float y) -> float {
    let z = x * x;
    let w = z * z;
    let r = z * (COS_C1 + z * (COS_C2 + z * COS_C3)) + w * w * (COS_C4 + z * (COS_C5 + z * COS_C6));
    let hz = 0.5 * z;
    let one_minus = 1.0 - hz;
    return one_minus + (((1.0 - one_minus) - hz) + (z * r - x * y));
}

// tan(x + y) for |x + y| <= pi/4 when `odd == 0`, else -1 / tan(x + y).
fn k_tan(float x, float y, int odd) -> float {
    let neg = x < 0.0;
    let big = fabs(x) >= KTAN_BIG;
    if big {
        if neg {
            x = -x;
            y = -y;
        }
        x = (PIO4 - x) + (PIO4_LO - y);
        y = 0.0;
    }
    let z = x * x;
    let w = z * z;
    let r = TAN_T1 + w * (TAN_T3 + w * (TAN_T5 + w * (TAN_T7 + w * (TAN_T9 + w * TAN_T11))));
    let v = z * (TAN_T2 + w * (TAN_T4 + w * (TAN_T6 + w * (TAN_T8 + w * (TAN_T10 + w * TAN_T12)))));
    let s = z * x;
    r = y + z * (s * (r + v) + y) + s * TAN_T0;
    w = x + r;
    if big {
        let sg = 1.0 - 2.0 * (odd as float);
        v = sg - 2.0 * (x + (r - w * w / (w + sg)));
        if neg {
            return -v;
        }
        return v;
    }
    if odd == 0 {
        return w;
    }
    // -1 / (x + r) accurately: w0 + v = x + r with w0 short, a0 short.
    let w0 = split_hi(w);
    v = r - (w0 - x);
    let a = -1.0 / w;
    let a0 = split_hi(a);
    return a0 + a * (1.0 + a0 * w0 + a0 * v);
}

/// Returns the sine of `x` radians.
/// # Examples
///
/// ```
/// use math::{sin};
/// use num::{PI, abs};
/// # use tests::assert;
/// assert!(sin(0.0) == 0.0);
/// assert!(abs(sin(PI / 2.0) - 1.0) < 0.000000000000001);
/// ```
fn sin(float x) -> float {
    let ax = fabs(x);
    if ax < PIO4_HW {
        if ax < SIN_SMALL {
            return x;
        }
        return k_sin(x, 0.0, 0);
    }
    if !(x - x == 0.0) {
        return x - x;
    }
    let (n, y0, y1) = rem_pio2(x);
    let quadrant = n & 3;
    if quadrant == 0 {
        return k_sin(y0, y1, 1);
    }
    if quadrant == 1 {
        return k_cos(y0, y1);
    }
    if quadrant == 2 {
        return -k_sin(y0, y1, 1);
    }
    return -k_cos(y0, y1);
}

/// Returns the cosine of `x` radians.
/// # Examples
///
/// ```
/// use math::{cos};
/// use num::{PI};
/// # use tests::assert;
/// assert!(cos(0.0) == 1.0);
/// assert!(cos(PI) == -1.0);
/// ```
fn cos(float x) -> float {
    let ax = fabs(x);
    if ax < PIO4_HW {
        if ax < COS_SMALL {
            return 1.0;
        }
        return k_cos(x, 0.0);
    }
    if !(x - x == 0.0) {
        return x - x;
    }
    let (n, y0, y1) = rem_pio2(x);
    let quadrant = n & 3;
    if quadrant == 0 {
        return k_cos(y0, y1);
    }
    if quadrant == 1 {
        return -k_sin(y0, y1, 1);
    }
    if quadrant == 2 {
        return -k_cos(y0, y1);
    }
    return k_sin(y0, y1, 1);
}

/// Returns the tangent of `x` radians.
/// # Examples
///
/// ```
/// use math::{tan};
/// use num::{PI, abs};
/// # use tests::assert;
/// assert!(tan(0.0) == 0.0);
/// assert!(abs(tan(PI / 4.0) - 1.0) < 0.000000000000001);
/// ```
fn tan(float x) -> float {
    let ax = fabs(x);
    if ax < PIO4_HW {
        if ax < TAN_SMALL {
            return x;
        }
        return k_tan(x, 0.0, 0);
    }
    if !(x - x == 0.0) {
        return x - x;
    }
    let (n, y0, y1) = rem_pio2(x);
    return k_tan(y0, y1, n & 1);
}

/// Returns the arc tangent of `x`, in radians in `[-pi/2, pi/2]`.
/// # Examples
///
/// ```
/// use math::{atan};
/// use num::{PI};
/// # use tests::assert;
/// assert!(atan(0.0) == 0.0);
/// assert!(atan(1.0) == PI / 4.0);
/// ```
fn atan(float x) -> float {
    if x != x {
        return x;
    }
    let neg = x < 0.0;
    let ax = fabs(x);
    if ax >= TWO66 {
        if neg {
            return -(ATANHI3 + TWO_M120);
        }
        return ATANHI3 + TWO_M120;
    }
    let id = -1;
    if ax < 0.4375 {
        if ax < TWO_M27 {
            return x;
        }
    } else {
        x = ax;
        if ax < 1.1875 {
            if ax < 0.6875 {
                id = 0;
                x = (2.0 * x - 1.0) / (2.0 + x);
            } else {
                id = 1;
                x = (x - 1.0) / (x + 1.0);
            }
        } else if ax < 2.4375 {
            id = 2;
            x = (x - 1.5) / (1.0 + 1.5 * x);
        } else {
            id = 3;
            x = -1.0 / x;
        }
    }
    let z = x * x;
    let w = z * z;
    let s1 = z * (ATAN_AT0 +
                  w * (ATAN_AT2 + w * (ATAN_AT4 + w * (ATAN_AT6 + w * (ATAN_AT8 + w * ATAN_AT10)))));
    let s2 = w * (ATAN_AT1 + w * (ATAN_AT3 + w * (ATAN_AT5 + w * (ATAN_AT7 + w * ATAN_AT9))));
    if id < 0 {
        return x - x * (s1 + s2);
    }
    let hi = ATANHI3;
    let lo = ATANLO3;
    if id == 0 {
        hi = ATANHI0;
        lo = ATANLO0;
    } else if id == 1 {
        hi = ATANHI1;
        lo = ATANLO1;
    } else if id == 2 {
        hi = ATANHI2;
        lo = ATANLO2;
    }
    let r = hi - (x * (s1 + s2) - lo - x);
    if neg {
        return -r;
    }
    return r;
}

/// Returns the angle of the point `(x, y)` from the positive x axis, in radians in `[-pi, pi]`.
///
/// Note the argument order: `y` first, as in C.
/// # Examples
///
/// ```
/// use math::{atan2};
/// use num::{PI};
/// # use tests::assert;
/// assert!(atan2(1.0, 1.0) == PI / 4.0);
/// assert!(atan2(0.0, -1.0) == PI);
/// assert!(atan2(-1.0, 0.0) == -PI / 2.0);
/// ```
fn atan2(float y, float x) -> float {
    if x != x || y != y {
        return x + y;
    }
    if x == 1.0 {
        return atan(y);
    }
    let sy = sign_bit(y);
    let sx = sign_bit(x);
    if y == 0.0 {
        if !sx {
            return y;
        }
        if sy {
            return -PI_HI;
        }
        return PI_HI;
    }
    if x == 0.0 {
        if sy {
            return -PIO2_HI;
        }
        return PIO2_HI;
    }
    let ax = fabs(x);
    let ay = fabs(y);
    if !(ax - ax == 0.0) {
        let r = 0.0;
        if !(ay - ay == 0.0) {
            r = PIO4;
            if sx {
                r = 3.0 * PIO4;
            }
        } else if sx {
            r = PI_HI;
        }
        if sy {
            return -r;
        }
        return r;
    }
    if !(ay - ay == 0.0) || ay > ax * TWO64 {
        if sy {
            return -PIO2_HI;
        }
        return PIO2_HI;
    }
    let z = 0.0;
    if !sx || !(ay * TWO64 < ax) {
        z = atan(fabs(y / x));
    }
    if !sx {
        if sy {
            return -z;
        }
        return z;
    }
    if sy {
        return (z - PI_LO) - PI_HI;
    }
    return PI_HI - (z - PI_LO);
}

// The rational approximation shared by asin and acos.
fn asin_r(float z) -> float {
    let p = z * (ASIN_PS0 +
                 z * (ASIN_PS1 + z * (ASIN_PS2 + z * (ASIN_PS3 + z * (ASIN_PS4 + z * ASIN_PS5)))));
    let q = 1.0 + z * (ASIN_QS1 + z * (ASIN_QS2 + z * (ASIN_QS3 + z * ASIN_QS4)));
    return p / q;
}

/// Returns the arc sine of `x`, in radians in `[-pi/2, pi/2]`; NaN outside `[-1, 1]`.
/// # Examples
///
/// ```
/// use math::{asin};
/// use num::{PI};
/// # use tests::assert;
/// assert!(asin(0.0) == 0.0);
/// assert!(asin(1.0) == PI / 2.0);
/// assert!(asin(2.0) != asin(2.0));
/// ```
fn asin(float x) -> float {
    let ax = fabs(x);
    if !(ax < 1.0) {
        if ax == 1.0 {
            return x * PIO2_HI + TWO_M120;
        }
        return 0.0 / (x - x);
    }
    if ax < 0.5 {
        if ax >= MIN_NORMAL && ax < SIN_SMALL {
            return x;
        }
        return x + x * asin_r(x * x);
    }
    let z = (1.0 - ax) * 0.5;
    let s = sqrt(z);
    let r = asin_r(z);
    let res = 0.0;
    if ax >= ASIN_975 {
        res = PIO2_HI - (2.0 * (s + s * r) - PIO2_LO);
    } else {
        // f + c = sqrt(z) with f short, so f * f is exact.
        let f = split_hi(s);
        let c = (z - f * f) / (s + f);
        res = 0.5 * PIO2_HI - (2.0 * s * r - (PIO2_LO - 2.0 * c) - (0.5 * PIO2_HI - 2.0 * f));
    }
    if x < 0.0 {
        return -res;
    }
    return res;
}

/// Returns the arc cosine of `x`, in radians in `[0, pi]`; NaN outside `[-1, 1]`.
/// # Examples
///
/// ```
/// use math::{acos};
/// use num::{PI};
/// # use tests::assert;
/// assert!(acos(1.0) == 0.0);
/// assert!(acos(-1.0) == PI);
/// assert!(acos(0.0) == PI / 2.0);
/// ```
fn acos(float x) -> float {
    let ax = fabs(x);
    if !(ax < 1.0) {
        if ax == 1.0 {
            if x < 0.0 {
                return 2.0 * PIO2_HI + TWO_M120;
            }
            return 0.0;
        }
        return 0.0 / (x - x);
    }
    if ax < 0.5 {
        if ax < ACOS_TINY {
            return PIO2_HI + TWO_M120;
        }
        return PIO2_HI - (x - (PIO2_LO - x * asin_r(x * x)));
    }
    if x < 0.0 {
        let z = (1.0 + x) * 0.5;
        let s = sqrt(z);
        let w = asin_r(z) * s - PIO2_LO;
        return 2.0 * (PIO2_HI - (s + w));
    }
    let z = (1.0 - x) * 0.5;
    let s = sqrt(z);
    let df = split_hi(s);
    let c = (z - df * df) / (s + df);
    let w = asin_r(z) * s + c;
    return 2.0 * (df + w);
}

/// Returns the hyperbolic sine of `x`.
/// # Examples
///
/// ```
/// use math::{sinh};
/// # use tests::assert;
/// assert!(sinh(0.0) == 0.0);
/// assert!(sinh(1.0) == 1.1752011936438014);
/// ```
fn sinh(float x) -> float {
    if x != x {
        return x;
    }
    let h = 0.5;
    if x < 0.0 {
        h = -0.5;
    }
    let ax = fabs(x);
    if ax < SINH_BIG {
        let t = expm1(ax);
        if ax < 1.0 {
            if ax < SIN_SMALL {
                return x;
            }
            return h * (2.0 * t - t * t / (t + 1.0));
        }
        return h * (t + t / (t + 1.0));
    }
    return 2.0 * h * expo2(ax);
}

/// Returns the hyperbolic cosine of `x`.
/// # Examples
///
/// ```
/// use math::{cosh};
/// # use tests::assert;
/// assert!(cosh(0.0) == 1.0);
/// assert!(cosh(1.0) == 1.5430806348152437);
/// ```
fn cosh(float x) -> float {
    if x != x {
        return x;
    }
    let ax = fabs(x);
    if ax < COSH_SMALL {
        if ax < SIN_SMALL {
            return 1.0;
        }
        let t = expm1(ax);
        return 1.0 + t * t / (2.0 * (1.0 + t));
    }
    if ax < SINH_BIG {
        let t = exp(ax);
        return 0.5 * (t + 1.0 / t);
    }
    return expo2(ax);
}

/// Returns the hyperbolic tangent of `x`, in `[-1, 1]`.
/// # Examples
///
/// ```
/// use math::{tanh};
/// # use tests::assert;
/// assert!(tanh(0.0) == 0.0);
/// assert!(tanh(30.0) == 1.0);
/// assert!(tanh(-30.0) == -1.0);
/// ```
fn tanh(float x) -> float {
    if x != x {
        return x;
    }
    let ax = fabs(x);
    let t = ax;
    if ax >= TANH_A {
        if ax >= TANH_B {
            t = 1.0 - 0.0 / ax;
        } else {
            t = expm1(2.0 * ax);
            t = 1.0 - 2.0 / (t + 2.0);
        }
    } else if ax >= TANH_C {
        t = expm1(2.0 * ax);
        t = t / (t + 2.0);
    } else if ax >= MIN_NORMAL {
        t = expm1(-2.0 * ax);
        t = -t / (t + 2.0);
    }
    if sign_bit(x) {
        return -t;
    }
    return t;
}
