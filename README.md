    Nama       : Zaki Jamali Arafi

    NIM        : H1D022048

    Shift Baru : D

# Tugas Pertemuan 5 - Penjelasan Proses Aplikasi Toko Kita

## Proses Login

### a. Form Login

![Screenshot form login](img/login.png)

Pengguna diminta untuk memasukkan email dan password pada form login.

Kode:

```dart
Widget _emailTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Email"),
    keyboardType: TextInputType.emailAddress,
    controller: _emailTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return 'Email harus diisi';
      }
      return null;
    },
  );
}

Widget _passwordTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Password"),
    keyboardType: TextInputType.text,
    obscureText: true,
    controller: _passwordTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Password harus diisi";
      }
      return null;
    },
  );
}
```

### b. Proses Autentikasi

![Screenshot proses login](img/proses_login.png)

Setelah menekan tombol login, aplikasi akan mengirim permintaan ke API untuk melakukan autentikasi.

Kode:

```dart
void _submit() {
  _formKey.currentState!.save();
  setState(() {
    _isLoading = true;
  });

  LoginBloc.login(
          email: _emailTextboxController.text,
          password: _passwordTextboxController.text)
      .then((value) async {
    if (value.code == 200) {
      await UserInfo().setToken(value.token ?? "");
      await UserInfo().setUserID(int.tryParse(value.userID.toString()) ?? 0);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessDialog(
          description: "Login berhasil",
          okClick: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ProdukPage(),
              ),
            );
          },
        ),
      );
    } else {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const WarningDialog(
                description: "Login gagal, silahkan coba lagi",
              ));
    }
  }, onError: (error) {
    print(error);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const WarningDialog(
              description: "Login gagal, silahkan coba lagi",
            ));
  });

  setState(() {
    _isLoading = false;
  });
}
```

### c. Hasil Login

![Screenshot popup berhasil login](img/sukses_login.png)
![Screenshot popup gagal login](img/gagal_login.png)

Setelah proses autentikasi, pengguna akan melihat popup yang menginformasikan hasil login (berhasil atau gagal).

## Proses Registrasi

### a. Form Registrasi

![Screenshot form registrasi](img/regist.png)

Pengguna diminta untuk mengisi nama, email, password, dan konfirmasi password.

Kode:

```dart
Widget _namaTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Nama"),
    keyboardType: TextInputType.text,
    controller: _namaTextboxController,
    validator: (value) {
      if (value!.length < 3) {
        return "Nama harus diisi minimal 3 karakter";
      }
      return null;
    },
  );
}

// ... (kode untuk email, password, dan konfirmasi password)
```

### b. Proses Pengiriman Data Registrasi

![Screenshot proses registrasi](img/proses_regist.png)

Setelah menekan tombol registrasi, aplikasi akan mengirim data ke API.

Kode:

```dart
void _submit() {
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    RegistrasiBloc.registrasi(
      nama: _namaTextboxController.text,
      email: _emailTextboxController.text,
      password: _passwordTextboxController.text,
    ).then((value) {
      if (value['status']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => SuccessDialog(
            description: "Registrasi berhasil, silahkan login",
            okClick: () {
              Navigator.pop(context);
            },
          ),
        );
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => WarningDialog(
            description: value['message'],
          ),
        );
      }
    }).catchError((error) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const WarningDialog(
          description: "Registrasi gagal, silahkan coba lagi",
        ),
      );
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }
```

### c. Hasil Registrasi

![Screenshot popup berhasil registrasi](img/sukses_regist.png)

Pengguna akan melihat popup yang menginformasikan hasil registrasi.

## Menampilkan Daftar Produk

### a. Halaman Utama Produk

![Screenshot halaman daftar produk](img/produk.png)

Setelah login berhasil, pengguna akan diarahkan ke halaman utama yang menampilkan daftar produk.

Kode:

```dart
class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);
  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Produk'),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                child: const Icon(Icons.add, size: 26.0),
                onTap: () async {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProdukForm()));
                },
              ))
        ],
      ),
      body: FutureBuilder<List>(
        future: ProdukBloc.getProduks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? ListProduk(
                  list: snapshot.data,
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
    );
  }
}
```

### b. Proses Pengambilan Data Produk

Data produk diambil dari API menggunakan `ProdukBloc.getProduks()`.

Kode:

```dart
class ProdukBloc {
  static Future<List<Produk>> getProduks() async {
    String apiUrl = ApiUrl.listProduk;
    var response = await Api().get(apiUrl);
    var jsonObj = json.decode(response.body);
    List<dynamic> listProduk = (jsonObj as Map<String, dynamic>)['data'];
    List<Produk> produks = [];
    for (int i = 0; i < listProduk.length; i++) {
      produks.add(Produk.fromJson(listProduk[i]));
    }
    return produks;
  }
}
```

## Menambah Produk Baru

### a. Form Tambah Produk

![Screenshot form tambah produk](img/tambah_produk.png)

Pengguna dapat menambah produk baru dengan menekan ikon "+" di halaman utama.

### b. Mengisi Data Produk Baru

Pengguna diminta untuk mengisi kode produk, nama produk, dan harga produk.

Kode:

```dart
Widget _kodeProdukTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Kode Produk"),
    keyboardType: TextInputType.text,
    controller: _kodeProdukTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Kode Produk harus diisi";
      }
      return null;
    },
  );
}

// ... (kode untuk nama produk dan harga produk)
```

### c. Proses Penyimpanan Produk Baru

![Screenshot proses tambah produk](img/proses_tambah_produk.png)

Setelah menekan tombol simpan, aplikasi akan mengirim data ke API.

Kode:

```dart
simpan() {
  setState(() {
    _isLoading = true;
  });
  Produk createProduk = Produk(id: null);
  createProduk.kodeProduk = _kodeProdukTextboxController.text;
  createProduk.namaProduk = _namaProdukTextboxController.text;
  createProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  ProdukBloc.addProduk(produk: createProduk).then((value) {
    if (value['status']) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => SuccessDialog(
          description: "Produk berhasil ditambahkan",
          okClick: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => const ProdukPage(),
              ),
            );
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => WarningDialog(
          description: value['message'],
        ),
      );
    }
  }).catchError((error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const WarningDialog(
        description: "Simpan gagal, silahkan coba lagi",
      ),
    );
  }).whenComplete(() {
    setState(() {
      _isLoading = false;
    });
  });
}
```

### d. Hasil Penambahan Produk

![Screenshot popup berhasil tambah produk](img/sukses_tambah.png)

Pengguna akan melihat popup yang menginformasikan hasil penambahan produk.

## Melihat Detail Produk

### a. Memilih Produk dari Daftar

[Screenshot pemilihan produk dari daftar]

Pengguna dapat melihat detail produk dengan menekan item produk di daftar.

### b. Halaman Detail Produk

![Screenshot halaman detail produk](img/detail_produk.png)

Halaman ini menampilkan informasi lengkap tentang produk yang dipilih.

Kode:

```dart
class ProdukDetail extends StatefulWidget {
  Produk? produk;
  ProdukDetail({Key? key, this.produk}) : super(key: key);
  @override
  _ProdukDetailState createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "Kode : ${widget.produk!.kodeProduk}",
              style: const TextStyle(fontSize: 20.0),
            ),
            Text(
              "Nama : ${widget.produk!.namaProduk}",
              style: const TextStyle(fontSize: 18.0),
            ),
            Text(
              "Harga : Rp. ${widget.produk!.hargaProduk.toString()}",
              style: const TextStyle(fontSize: 18.0),
            ),
            _tombolHapusEdit()
          ],
        ),
      ),
    );
  }

  // ...
}
```

## Mengubah Produk

### a. Form Ubah Produk

![Screenshot form ubah produk](img/ubah.png)

Dari halaman detail produk, pengguna dapat menekan tombol "EDIT" untuk membuka form ubah produk.

### b. Mengisi Perubahan Data Produk

Form ubah produk akan terisi dengan data produk yang ada, dan pengguna dapat mengubahnya.

### c. Proses Penyimpanan Perubahan

![Screenshot proses ubah produk](img/proses_ubah.png)

Setelah menekan tombol ubah, aplikasi akan mengirim data perubahan ke API.

Kode:

```dart
ubah() {
  setState(() {
    _isLoading = true;
  });
  Produk updateProduk = Produk(id: widget.produk!.id!);
  updateProduk.kodeProduk = _kodeProdukTextboxController.text;
  updateProduk.namaProduk = _namaProdukTextboxController.text;
  updateProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  ProdukBloc.updateProduk(produk: updateProduk).then((value) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        description: "Produk berhasil diubah",
        okClick: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => const ProdukPage(),
            ),
          );
        },
      ),
    );
  }, onError: (error) {
    showDialog(
        context: context,
        builder: (BuildContext context) => const WarningDialog(
              description: "Permintaan ubah data gagal, silahkan coba lagi",
            ));
  });
  setState(() {
    _isLoading = false;
  });
}
```

### d. Hasil Perubahan Produk

![Screenshot popup berhasil ubah produk](img/sukses_ubah.png)

Pengguna akan melihat popup yang menginformasikan hasil perubahan produk.

## Menghapus Produk

### a. Memilih Produk untuk Dihapus

Dari halaman detail produk, pengguna dapat menekan tombol "DELETE" untuk menghapus produk.

### b. Konfirmasi Penghapusan

![Screenshot dialog konfirmasi hapus](img/dialog.png)

Sebelum menghapus, aplikasi akan menampilkan dialog konfirmasi.

Kode:

```dart
void confirmHapus() {
  AlertDialog alertDialog = AlertDialog(
    content: const Text("Yakin ingin menghapus data ini?"),
    actions: [
      OutlinedButton(
        child: const Text("Ya"),
        onPressed: () async {
          // Proses penghapusan
        },
      ),
      OutlinedButton(
        child: const Text("Batal"),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
  showDialog(builder: (context) => alertDialog, context: context);
}
```

### c. Proses Penghapusan

Jika pengguna mengkonfirmasi, aplikasi akan mengirim permintaan hapus ke API.

Kode:

```dart
onPressed: () async {
  bool success = await ProdukBloc.deleteProduk(
      id: int.parse(widget.produk!.id!));
  if (success) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => SuccessDialog(
        description: "Produk berhasil dihapus",
        okClick: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const ProdukPage(),
            ),
          );
        },
      ),
    );
  } else {
    // Jika penghapusan gagal
    showDialog(
      context: context,
      builder: (BuildContext context) => const WarningDialog(
        description: "Hapus gagal, silahkan coba lagi",
      ),
    );
  }
},
```

### d. Hasil Penghapusan Produk

![Screenshot popup berhasil hapus produk](img/sukses_hapus.png)

Pengguna akan melihat popup yang menginformasikan hasil penghapusan produk.

## Proses Logout

### a. Memilih Menu Logout

![Screenshot drawer dengan menu logout](img/logout.png)

Pengguna dapat mengakses menu logout dari drawer aplikasi.

Kode:

```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        title: const Text('Logout'),
        trailing: const Icon(Icons.logout),
        onTap: () async {
          await LogoutBloc.logout().then((value) => {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false)
              });
        },
      )
    ],
  ),
),
```

### b. Proses Logout

Ketika pengguna memilih logout, aplikasi akan menghapus token dan informasi pengguna dari penyimpanan lokal.

Kode:

```dart
class LogoutBloc {
  static Future logout() async {
    await UserInfo().logout();
  }
}

// Di dalam class UserInfo
Future logout() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.clear();
}
```

### c. Kembali ke Halaman Login

Setelah proses logout selesai, pengguna akan diarahkan kembali ke halaman login.