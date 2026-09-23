import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isError = false
    var isMultiline = false
    var isSecure = false

    @FocusState private var isFocused: Bool

    private var showsClearButton: Bool {
        isFocused && !text.isEmpty && !isMultiline && !isSecure
    }

    var body: some View {
        HStack(spacing: 8) {
            field
                .font(.regular17)
                .foregroundStyle(Color(.fnText))
                .tint(Color(.fnBlue))
                .focused($isFocused)

            if showsClearButton {
                Button { text = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Color(uiColor: .systemGray))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .frame(minHeight: 46)
        .background(Color(.fnLightGray), in: .rect(cornerRadius: 12))
        .overlay {
            if isError {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.fnRed), lineWidth: 1)
            }
        }
    }

    @ViewBuilder
    private var field: some View {
        let prompt = Text(placeholder).foregroundStyle(Color(.fnGray))
        if isSecure {
            SecureField("", text: $text, prompt: prompt)
        } else {
            TextField("", text: $text, prompt: prompt, axis: isMultiline ? .vertical : .horizontal)
        }
    }
}

#Preview {
    @Previewable @State var empty = ""
    @Previewable @State var filled = "email.com"
    @Previewable @State var description = "Дизайнер из Казани, люблю цифровое искусство и бейглы."
    @Previewable @State var password = "secret"

    VStack(spacing: 16) {
        AppTextField(placeholder: "Описание", text: $description, isMultiline: true)
        AppTextField(placeholder: "Email", text: $empty)
        AppTextField(placeholder: "Пароль", text: $password, isSecure: true)
        AppTextField(placeholder: "Поле с ошибкой", text: $filled, isError: true)
    }
    .padding()
}
