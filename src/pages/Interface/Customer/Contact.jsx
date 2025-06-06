import ContactSection from "../../../components/ContactSection";

const Contact = () => {
  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">
              Liên hệ với chúng tôi
            </h1>
            <p className="text-gray-200 text-lg">
              Bạn có thắc mắc hoặc cần hỗ trợ pháp lý? Nhóm của chúng tôi luôn
              sẵn sàng trợ giúp. Hãy liên hệ với chúng tôi thông qua bất kỳ
              phương pháp nào dưới đây.
            </p>
          </div>
        </div>
      </section>

      <ContactSection />
    </main>
  );
};

export default Contact;
