import SwiftUI

struct AlertModel: Identifiable {
    let id = UUID()
    let title: LocalizedStringResource
    let message: LocalizedStringResource?
    let primaryButton: Button
    let secondaryButton: Button?

    struct Button {
        let title: LocalizedStringResource
        let role: ButtonRole?
        let action: () -> Void

        init(title: LocalizedStringResource, role: ButtonRole? = nil, action: @escaping () -> Void = {}) {
            self.title = title
            self.role = role
            self.action = action
        }
    }
}

extension AlertModel {
    static func retryError(title: LocalizedStringResource, onRetry: @escaping () -> Void) -> AlertModel {
        AlertModel(
            title: title,
            message: nil,
            primaryButton: Button(title: AlertLocalizedText.retry.resource, action: onRetry),
            secondaryButton: Button(title: AlertLocalizedText.cancel.resource, role: .cancel)
        )
    }

    static func info(title: LocalizedStringResource, message: LocalizedStringResource? = nil) -> AlertModel {
        AlertModel(
            title: title,
            message: message,
            primaryButton: Button(title: AlertLocalizedText.ok.resource, role: .cancel),
            secondaryButton: nil
        )
    }

    static func confirmation(
        title: LocalizedStringResource,
        message: LocalizedStringResource? = nil,
        confirmTitle: LocalizedStringResource,
        cancelTitle: LocalizedStringResource = AlertLocalizedText.cancel.resource,
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
            item.wrappedValue.map { Text($0.title) } ?? Text(verbatim: ""),
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            presenting: item.wrappedValue
        ) { model in
            SwiftUI.Button(role: model.primaryButton.role) {
                model.primaryButton.action()
            } label: {
                Text(model.primaryButton.title)
            }
            if let secondary = model.secondaryButton {
                SwiftUI.Button(role: secondary.role) {
                    secondary.action()
                } label: {
                    Text(secondary.title)
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
                alert = .retryError(title: CatalogLocalizedText.loadError.resource) {}
            } label: {
                Text(verbatim: "Ошибка + Повторить")
            }
            Button {
                alert = .info(
                    title: CartLocalizedText.paymentError.resource,
                    message: CatalogLocalizedText.likeError.resource
                )
            } label: {
                Text(verbatim: "Сообщение (OK)")
            }
            Button {
                alert = .confirmation(
                    title: CartLocalizedText.deleteConfirmation.resource,
                    confirmTitle: CartLocalizedText.delete.resource,
                    cancelTitle: CartLocalizedText.back.resource
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
