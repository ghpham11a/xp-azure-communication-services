import Foundation

enum ChatEndpoints {
    struct CreateThread: Endpoint {
        let path = "/chat/thread"
        let method = HTTPMethod.post
        let body: Data?

        init(userId: String, displayName: String, topic: String) throws {
            self.body = try JSONEncoder().encode(
                CreateThreadRequest(userId: userId, displayName: displayName, topic: topic)
            )
        }
    }

    struct JoinThread: Endpoint {
        let path: String
        let method = HTTPMethod.post
        let body: Data?

        init(threadId: String, userId: String, displayName: String) throws {
            self.path = "/chat/thread/\(threadId)/join"
            self.body = try JSONEncoder().encode(
                JoinThreadRequest(userId: userId, displayName: displayName)
            )
        }
    }
}
