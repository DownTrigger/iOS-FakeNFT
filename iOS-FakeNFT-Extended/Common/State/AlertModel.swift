import SwiftUI

struct AlertModel: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
    let primaryButton: Button
    let secondaryButton: Button?

    struct Button {
        let title: String
        let role: ButtonRole?
        let action: () -> Void

        init(title: String, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.action = action
        }
    }
}

extension AlertModel {
    static func retryError(title: String, onRetry: @escaping () -> Void) -> AlertModel {
        AlertModel(
            title: title,
            message: nil,
            primaryButton: Button(title: String(localized: "Error.repeat"), action: onRetry),
            secondaryButton: Button(title: String(localized: "Alert.cancel"), role: .cancel)
        )
    }

    static func info(title: String, message: String? = nil) -> AlertModel {
        AlertModel(
            title: title,
            message: message,
            primaryButton: Button(title: String(localized: "Alert.ok"), role: .cancel),
            secondaryButton: nil
        )
    }

    static func confirmation(
        title: String,
        message: String? = nil,
        confirmTitle: String,
        cancelTitle: String = String(localized: "Alert.cancel"),
        role: ButtonRole? = nil,
        onConfirm: @escaping () -> Void
    ) -> AlertModel {
        AlertModel(
            title: title,
            message: message,
            primaryButton: Button(title: confirmTitle, role: role, action: onConfirm),
            secondaryButton: Button(title: cancelTitle, role: .cancel)
        )
    }
}

extension View {
    func appAlert(item: Binding<AlertModel?>) -> some View {
        alert(
            item.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            presenting: item.wrappedValue
        ) { model in
            SwiftUI.Button(model.primaryButton.title, role: model.primaryButton.role) {
                model.primaryButton.action()
            }
            if let secondary = model.secondaryButton {
                SwiftUI.Button(secondary.title, role: secondary.role) {
                    secondary.action()
                }
            }
        } message: { model in
            if let message = model.message {
                Text(message)
            }
        }
    }
}

private struct AlertPreviewHost: View {
    @State private var alert: AlertModel?

    var body: some View {
        VStack(spacing: 16) {
            Button {
                alert = .retryError(title: "Не удалось получить данные") {}
            } label: {
                Text(verbatim: "Ошибка + Повторить")
            }
            Button {
                alert = .info(title: "Что-то пошло не так(", message: "Не удалось войти в систему")
            } label: {
                Text(verbatim: "Сообщение (OK)")
            }
            Button {
                alert = .confirmation(
                    title: "Уверены, что хотите выйти?",
                    confirmTitle: "Выйти",
                    cancelTitle: "Остаться"
                ) {}
            } label: {
                Text(verbatim: "Подтверждение")
            }
        }
        .appAlert(item: $alert)
    }
}

#Preview {
    AlertPreviewHost()
}
